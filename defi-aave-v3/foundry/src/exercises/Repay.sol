// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IPool} from "../interfaces/aave-v3/IPool.sol";
import {IVariableDebtToken} from "../interfaces/aave-v3/IVariableDebtToken.sol";
import {POOL} from "../Constants.sol";
import {
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Repay {
    using safeERC20 for IERC20;

    IPool public constant pool = IPool(POOL);

    function supply(address token, uint256 amount) public {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(address(pool), amount);
        pool.supply({
            asset: token,
            amount: amount,
            onBehalfOf: address(this),
            referralCode: 0
        });
    }

    function borrow(address token, uint256 amount) public {
        pool.borrow({
            asset: token,
            amount: amount,
            // 1 = Stable interest rate
            // 2 = Variable interest rate
            interestRateMode: 2,
            referralCode: 0,
            onBehalfOf: address(this)
        });
    }

    function getVariableDebt(address token) public view returns (uint256) {
        IPool.ReserveData memory reserve = pool.getReserveData(token);
        return IERC20(reserve.variableDebtTokenAddress).balanceOf(address(this));
    }

    // Task 1 - Repay all the debt owed to Aave V3
    // -Contract holds some tokens leftover from supply/borrowand owes debt.
    // -User needs to cover the shortfall
    // shortfall = debt - contractBalance
    // -If debt > balance -> pull shortfall from user : debt<= balance ->contract already has enough, pull nothing.
    // -Approve the pool for the full debt(not shortfall), repay with type(uint256).max
    function repay(address token) public returns (uint256) {
        // Task 1.1
        // msg.sender will pay for the interest on borrow.
        // Transfer the difference (debt - balance in this contract)
        uint256 debt = getVariableDebt(token);
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        // uint256 shortFall = debt > contractBalance; //-> this evaluates to a boolean(true = 1, false = 0)

        // User tops up the difference(shortfall)
        if(debt > contractBalance){
            uint256 shortFall = debt - contractBalance;//guarantees no underflow reverts.
            IERC20(token).safeTransferFrom(msg.sender, address(this), shortFall); //pulling from user if contract is short
        }

        // Task 1.2 - Approve the pool contract to transfer debt from this contract
        // contract approves full debt.
        IERC20(token).approve(address(pool), debt); //let pool pull what it needs

        // Task 1.3 - Repay all the debt to Aave V3
        // All the debt can be repaid by setting the amount to repay to a number
        // greater than or equal to the current debt
        // Aave pulls what it's owed.
        uint256 repaid = pool.repay({asset: token,
        amount: type(uint256).max,// repay ALL
        interestRateMode: 2,
        onBehalfOf: address(this)}
    );

        // Task 1.4 - Return the amount that was repaid
        return repaid;
    }
}
