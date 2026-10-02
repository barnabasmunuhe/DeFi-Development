// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {POOL, WETH} from "../src/Constants.sol";
import {IPool} from "../src/interfaces/aave-v3/IPool.sol";
import {Withdraw} from "@exercises/Withdraw.sol";

contract WithdrawTest is Test {
    // setting up shortcuts to talk to other smart contracts on the Blockchain.
    // standardized links interfaces that allow my test contract to send them instructions.
    IERC20 private constant weth = IERC20(WETH);//binding address WETH to the standard IERC20 interface/rulebook
    IPool private constant pool = IPool(POOL); //binding address POOL to the IPool rulebook
    IERC20 private aWeth; //using IERC20 rulebook to create AToken(aWeth) slot.
    Withdraw private withdrawInstance;// Getting the test contract ready to hold a copy of the withdraw contract

    uint256 amount = 1e18;

    function setUp() public {
        // Get aWETH address
        IPool.ReserveData memory reserve = pool.getReserveData(WETH);
        aWeth = IERC20(reserve.aTokenAddress);

        deal(WETH, address(this), amount); //wiring some WETH to this test contract
        withdrawInstance = new Withdraw();

        weth.approve(address(withdrawInstance), amount); //Approving the withdraw contract to use the WETH token we minted from thin air in our test contract.
        withdrawInstance.supply(WETH, amount); // using the wthdraw's supply function to add the minted WETH to the pool.(test contract will act as the user/suplier)

        // Let supply interest increase within a & day period in seconds
        skip(7 * 24 * 3600);
    }

    function test_withdraw() public {
        uint256 aWethBalBefore = aWeth.balanceOf(address(withdrawInstance));
        uint256 withdrawn = withdrawInstance.withdraw(WETH, type(uint256).max);
        uint256 aWethBalAfter = aWeth.balanceOf(address(withdrawInstance));

        console.log("WETH balance: %e", aWethBalBefore);

        assertGt(aWethBalBefore, 0, "aWETH balance = 0");
        assertEq(aWethBalAfter, 0, "aWETH balance after MUST be 0");
        assertEq(withdrawn, aWethBalBefore, "aWETH balance");
        assertEq(
            weth.balanceOf(address(withdrawInstance)), withdrawn, "WETH balance of withdrawInstance"
        );
    }
}
