// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {POOL, WETH} from "../src/Constants.sol";
import {IPool} from "../src/interfaces/aave-v3/IPool.sol";
import {Supply} from "@exercises/Supply.sol";

contract SupplyTest is Test {
    IERC20 private constant weth = IERC20(WETH);
    IPool private constant pool = IPool(POOL);
    IERC20 private aWeth;
    Supply private newSupplyContractInstance;

    uint256 amount = 1e18;

    function setUp() public {
        // Get aWETH address
        IPool.ReserveData memory reserve = pool.getReserveData(WETH);
        aWeth = IERC20(reserve.aTokenAddress);

        deal(WETH, address(this), 1e18);
        newSupplyContractInstance = new Supply();
    }

    function test_supply() public {
        uint256 wethBalBefore = weth.balanceOf(address(this));
        weth.approve(address(newSupplyContractInstance), amount);
        newSupplyContractInstance.supply(WETH, amount);
        uint256 wethBalAfter = weth.balanceOf(address(this));

        assertTrue(amount >= 0, "amount must be non-negative");
        assertEq(
            wethBalBefore - wethBalAfter, amount, "WETH balance of test contract"
        );
        assertEq(weth.balanceOf(address(newSupplyContractInstance)), 0, "WETH balance of target");
        assertGt(aWeth.balanceOf(address(newSupplyContractInstance)), 0, "aWETH balance of target");
        assertEq(
            newSupplyContractInstance.getSupplyBalance(WETH),
            aWeth.balanceOf(address(newSupplyContractInstance)),
            "Supply balance"
        );
    }
}
