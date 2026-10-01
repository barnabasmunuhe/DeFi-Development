// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {POOL, ORACLE, WETH, DAI} from "../src/Constants.sol";
import {IPool} from "../src/interfaces/aave-v3/IPool.sol";
import {IAaveOracle} from "../src/interfaces/aave-v3/IAaveOracle.sol";
import {Repay} from "@exercises/Repay.sol";
import {
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RepayTest is Test {
    IERC20 private constant weth = IERC20(WETH);//handle to WETH token
    IERC20 private constant dai = IERC20(DAI); //handle to DAI token
    IPool private constant pool = IPool(POOL);//handle to Aave Pool
    IAaveOracle private constant oracle = IAaveOracle(ORACLE); //handle to Aave Oracle
    IERC20 private debtToken; //holds the DAI variable debt token address
    Repay private repayInstance;//repay contract instance using it for testing

    function setUp() public { //runs before any tests
        uint256 amount = 1e18;

        deal(WETH, address(this), amount); //wiring 1 WETH to the test contract 
        repayInstance = new Repay();// deploying the repay Contract

        weth.approve(address(repayInstance), amount); //approving the repay contract to spend our tokens
        repayInstance.supply(WETH, amount); //supplying WETH amount through the Repay contract.(Repay contract now owns AWeth collateral token) inside Aave

        IPool.ReserveData memory reserve = pool.getReserveData(DAI); //fetching ReserveData struct from Pool Interface. 
        debtToken = IERC20(reserve.variableDebtTokenAddress);//ectracting the variable debt token address from the ReserveData struct

        // calculating how much DAI can be borrowed
        (,, uint256 availableToBorrowUsd,,,) =
            pool.getUserAccountData(address(repayInstance));

        // Approximate max borrow = available USD * DAI decimals / 1e8
        // 1 USD = 1e8
        uint256 approxMaxBorrow = availableToBorrowUsd * (10 ** 10); //converting USD to DAI.
        // 50% of approx max borrow
        uint256 borrowAmount = approxMaxBorrow * 50 / 100; //Borrowing 50% of the available converted DAI
        console.log("Approximate max borrow: %e", approxMaxBorrow);
        console.log("Borrow amount: %e", borrowAmount);
        repayInstance.borrow(DAI, borrowAmount); //calling wrapper's borrow(repayInstance) through the Repay contract.

        // Mint DAI and allow repayInstance to spend
        deal(DAI, address(this), 1000 * amount); // funding the test contract with 1000 DAI to pay off interest later
        dai.approve(address(repayInstance), type(uint256).max);  //Approve repay contract to pull unlimited DAI incase of any shortfall
    }

    // Test's job: give the wrapper(Repay contract) collateral -> borrow -> skip time -> repay -> verify debt is gone
    function test_repay() public {
        // Test increase in debt over time
        // -Snapshot before time passes.
        uint256 debtBalanceBeforeRepay = debtToken.balanceOf(address(repayInstance));
        console.log("Debt: %e", debtBalanceBeforeRepay);
        assertEq(debtBalanceBeforeRepay, repayInstance.getVariableDebt(DAI), "Asserting Debt Balance Before Repay == DAI amount in the Repay contract");

        skip(7 * 24 * 3600); //7 days in seconds forwarding so that interest accrues

        // Verifying debt grew
        uint256 debtBalanceAfter7Days = debtToken.balanceOf(address(repayInstance));
        console.log("Debt: %e", debtBalanceAfter7Days);
        assertEq(debtBalanceAfter7Days, repayInstance.getVariableDebt(DAI), "Debt After 7 days");//verifying the repay contract balance matches the variable debt balance of the DAI token

        // Test before repay
        assertGt(debtToken.balanceOf(address(repayInstance)), 0, "debt before repay");
        assertGt(dai.balanceOf(address(repayInstance)), 0, "DAI before repay");

        uint256 repaid = repayInstance.repay(DAI);

        // Test After repay
        assertEq(debtToken.balanceOf(address(repayInstance)), 0, "debt after repay");
        assertEq(dai.balanceOf(address(repayInstance)), 0, "DAI after repay");
        assertGt(repaid, 0, "repaid");//asserting repaid amount is greater than 0
    }
}
