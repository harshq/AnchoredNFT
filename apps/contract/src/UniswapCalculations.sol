// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {Constants} from "src/Constants.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {OracleLibrary} from "v3-periphery/libraries/OracleLibrary.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {PrecisionScaler} from "src/PrecisionScaler.sol";

library UniswapCalculations {
    error NFTEngine__TwapQuoteIsZero();

    struct QuoteContext {
        address collateralBase;
        address collateralToken;
        address collateralPool;
        uint8 collateralDecimals;
        uint8 baseDecimals;
    }

    function getTwapQuoteUnit(QuoteContext memory ctx, uint32[] memory timeAgo)
        private
        view
        returns (uint256 normalizedTwapUnit)
    {
        (int56[] memory tickCumulatives,) = IUniswapV3Pool(ctx.collateralPool).observe(timeAgo);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        int56 twapTick = tickCumulativesDelta / int56(int256(Constants.PRICE_CHANGE_DURATION));

        normalizedTwapUnit = PrecisionScaler.normalizeToSystemPrecision(
            OracleLibrary.getQuoteAtTick(
                int24(twapTick), uint128(10 ** ctx.collateralDecimals), ctx.collateralToken, ctx.collateralBase
            ),
            ctx.baseDecimals
        );
    }

    function getCurrentQuoteUnit(QuoteContext memory ctx)
        private
        view
        returns (uint256 normalizedCurrentUnit, int24 currentTick)
    {
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(ctx.collateralPool).slot0();
        currentTick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);

        normalizedCurrentUnit = PrecisionScaler.normalizeToSystemPrecision(
            OracleLibrary.getQuoteAtTick(
                currentTick, uint128(10 ** ctx.collateralDecimals), ctx.collateralToken, ctx.collateralBase
            ),
            ctx.baseDecimals
        );
    }

    function getRelativePriceChange(
        address collateralBase,
        address collateralToken,
        address collateralPool,
        uint256 collateralAmount
    ) public view returns (int256 relativeChange, int256 collateralValueUsd) {
        // timeAgo array
        uint32[] memory timeAgo = new uint32[](2);
        timeAgo[0] = uint32(Constants.PRICE_CHANGE_DURATION);
        timeAgo[1] = 0;

        // context for quote calc
        QuoteContext memory ctx = QuoteContext({
            collateralBase: collateralBase,
            collateralToken: collateralToken,
            collateralPool: collateralPool,
            collateralDecimals: IERC20Metadata(collateralToken).decimals(),
            baseDecimals: IERC20Metadata(collateralBase).decimals()
        });

        // normalized unit price
        uint256 normalizedTwapUnit = getTwapQuoteUnit(ctx, timeAgo);
        (uint256 normalizedCurrentUnit, int24 currentTick) = getCurrentQuoteUnit(ctx);

        if (normalizedTwapUnit == 0) revert NFTEngine__TwapQuoteIsZero();

        // calc relative change
        relativeChange = (
            (int256(normalizedCurrentUnit) - int256(normalizedTwapUnit)) * int256(Constants.PRECISION_FACTOR)
        ) / int256(normalizedTwapUnit);

        // collateral value in base token
        uint256 currentQuoteForAmount = OracleLibrary.getQuoteAtTick(
            currentTick,
            uint128(PrecisionScaler.normalizeToPrecision(collateralAmount, Constants.DECIMALS, ctx.collateralDecimals)),
            ctx.collateralToken,
            ctx.collateralBase
        );

        collateralValueUsd = int256(PrecisionScaler.normalizeToSystemPrecision(currentQuoteForAmount, ctx.baseDecimals));
    }
}
