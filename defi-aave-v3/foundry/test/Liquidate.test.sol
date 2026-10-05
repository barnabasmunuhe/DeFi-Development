// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {POOL, ORACLE, WETH, DAI} from "../src/Constants.sol";
import {IPool} from "../src/interfaces/aave-v3/IPool.sol";
import {IAaveOracle} from "../src/interfaces/aave-v3/IAaveOracle.sol";
import {Liquidate} from "@exercises/Liquidate.sol";

contract LiquidateTest is Test {
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IPool private constant pool = IPool(POOL);
    IAaveOracle private constant oracle = IAaveOracle(ORACLE);
    Liquidate private liquidateInstance;

    uint256 amount = 1e18;

    function setUp() public {
        // Supply
        deal(WETH, address(this), amount);//wiring test cintract some WETH.
        weth.approve(address(pool), type(uint256).max); //approving the pool contract to spend our tokens.
        pool.supply({
            asset: WETH,
            amount: amount,
            onBehalfOf: address(this),
            referralCode: 0
        });//supplying WETH collateral to the pool

        // Borrow
        // (FAKING ETH PRICE = $2000)-whenever anything queries the Aave Oracle for WETH's price return $2000
        vm.mockCall(
            ORACLE,
            abi.encodeCall(IAaveOracle.getAssetPrice, (WETH)),
            abi.encode(uint256(2000 * 1e8))
        );
        pool.borrow({//borrowing DAI tokens
            asset: DAI,
            amount: 1000 * 1e18,
            interestRateMode: 2,
            referralCode: 0,
            onBehalfOf: address(this)
        });

        // (CRASHING ETH price t0 $500)
        uint256 ethPrice = 500 * 1e8;

        vm.mockCall(
            ORACLE,
            abi.encodeCall(IAaveOracle.getAssetPrice, (WETH)),
            abi.encode(ethPrice)
        );

        liquidateInstance = new Liquidate(); // deploying new liquidate contract.

        // Approve liquidateInstance contract to spend DAI
        deal(DAI, address(this), 10000 * amount); //minting loan DAI
        dai.approve(address(liquidateInstance), 10000 * amount);
    }

    function test_liquidate() public {
        // reading borrower's total collateral & debt in USD
        (uint256 colUsdBefore, uint256 debtUsdBefore,,,,) = pool.getUserAccountData(address(this));

        liquidateInstance.liquidate(WETH, DAI, address(this));

        // Snapshot after
        (uint256 colUsdAfter, uint256 debtUsdAfter,,,,) = pool.getUserAccountData(address(this));

        assertLt(colUsdAfter, colUsdBefore, "USD collateral after");
        assertLt(debtUsdAfter, debtUsdBefore, "USD debt after");

        uint256 wethBal = weth.balanceOf(address(liquidateInstance));
        console.log("WETH balance: %e", wethBal);
        assertGt(wethBal, 0, "WETH balance");
    }
}
