// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {console} from "forge-std/Test.sol";
import {IPool} from "../interfaces/aave-v3/IPool.sol";
import {POOL} from "../Constants.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Liquidate {
    using SafeERC20 for IERC20;

    IPool public constant pool = IPool(POOL);

    // Task 1 - Liquidate an under-collateralized loan
    function liquidate(address collateral, address borrowedToken, address user)
        public {
        // Task 1.1 - Get the amount of borrowed token that the user owes to Aave V3
        // (,uint256 totalDebtBase,,,,) = pool.getUserAccountData(user);//TOTAL DEBT ACROSS ALL RESERVES
        // ->1. Get actual debt in borrowedToken units
        IPool.ReserveData memory reserve = pool.getReserveData(borrowedToken);
        uint256 debt = IERC20(reserve.variableDebtTokenAddress).balanceOf(user);

        // Task 1.2 - Transfer the full borrowed amount from msg.sender
        // ->2.Pull debt from caller
        IERC20(borrowedToken).safeTransferFrom(msg.sender,address(this), debt);

        // Task 1.3 - Approve the pool contract to spend borrowed token from this contract
        // ->3. Approve pool
        IERC20(borrowedToken).approve(address(pool), debt);

        // Task 1.4 - Call liquidate
        // 4->LIQUIDATE.
        pool.liquidationCall({
        collateralAsset: collateral,
        debtAsset: borrowedToken,
        user: user,
        debtToCover: debt,
        receiveAToken: false
        });
    }
}
