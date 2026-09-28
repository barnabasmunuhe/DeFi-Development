// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {POOL, ORACLE, WETH, DAI} from "../src/Constants.sol";
import {IPool} from "../src/interfaces/aave-v3/IPool.sol";
import {IAaveOracle} from "../src/interfaces/aave-v3/IAaveOracle.sol";
import {Borrow} from "@exercises/Borrow.sol";

contract BorrowTest is Test {
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IPool private constant pool = IPool(POOL);
    IAaveOracle private constant oracle = IAaveOracle(ORACLE);
    IERC20 private debtToken;
    Borrow private borrowContract; //making a new Borrow Contract Instance for the tests operations

    uint256 amount = 1e18;
    uint256 amountToBorrow = 100 * 1e18;

    function setUp() public {
        IPool.ReserveData memory reserve = pool.getReserveData(DAI);
        debtToken = IERC20(reserve.variableDebtTokenAddress);

        deal(WETH, address(this), amount);
        borrowContract = new Borrow();// Deploying the borrow contract

        weth.approve(address(borrowContract), amount); //approving the borrowContract to spend the amount(1e18)...Approving the contract to spend only 1e18
        borrowContract.supply(WETH, amount); //Supplying the WETH token to our test contract for testing
    }

    function test_borrow() public {
        uint256 wethPrice = oracle.getAssetPrice(WETH);
        uint256 approxMaxBorrow = borrowContract.approxMaxBorrow(DAI);
        uint256 hf = borrowContract.getHealthFactor();

        // %e is just a Scientific (exponential) notation
        console.log("WETH price: %e", wethPrice);
        console.log("Approximate max borrow: %e", approxMaxBorrow);
        console.log("Health factor: %e", hf);

        assertGt(hf, 0, "Health factor");
        assertGt(approxMaxBorrow, 0, "Approximate max borrow");
        assertEq(borrowContract.getVariableDebt(DAI), 0, "Variable debt before borrow");

        borrowContract.borrow(DAI, amountToBorrow); //borrowing the DAI token

        uint256 bal = dai.balanceOf(address(borrowContract));
        uint256 debt = debtToken.balanceOf(address(borrowContract));

        console.log("DAI balance: %e", bal);
        console.log("DAI debt: %e", debt);

        assertEq(bal, amountToBorrow, "DAI balance");
        assertGe(debt, bal, "Debt");
        assertEq(
            borrowContract.getVariableDebt(DAI), debt, "Variable debt after borrow"
        );
    }
}
