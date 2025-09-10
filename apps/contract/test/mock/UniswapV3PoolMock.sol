// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "@uniswap/v3-core/contracts/libraries/TickMath.sol";

interface IUniswapV3PoolMock {
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
}

contract UniswapV3PoolMock is IUniswapV3PoolMock {
    uint160 public sqrtPriceX96_;
    int24 public currentTick_;
    int24 public pastTick_;
    uint32 public secondsAgo_;
    uint8 public decimalsToken0_;
    uint8 public decimalsToken1_;

    constructor(
        uint256 currentPrice,
        uint256 pastPrice,
        uint32 secondsAgo,
        uint8 decimalsToken0,
        uint8 decimalsToken1
    ) {
        decimalsToken0_ = decimalsToken0;
        decimalsToken1_ = decimalsToken1;
        secondsAgo_ = secondsAgo;

        // Convert prices to sqrtPriceX96 using decimals
        sqrtPriceX96_ = _priceToSqrtPriceX96(currentPrice, decimalsToken0, decimalsToken1);

        // Compute ticks
        currentTick_ = TickMath.getTickAtSqrtRatio(sqrtPriceX96_);
        pastTick_ = TickMath.getTickAtSqrtRatio(_priceToSqrtPriceX96(pastPrice, decimalsToken0, decimalsToken1));
    }

    /// @notice Mock Uniswap V3 observe (returns tick cumulatives for TWAP)
    function observe(uint32[] calldata secondsAgos)
        external
        view
        override
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
    {
        tickCumulatives = new int56[](secondsAgos.length);
        secondsPerLiquidityCumulativeX128s = new uint160[](secondsAgos.length);

        for (uint256 i = 0; i < secondsAgos.length; i++) {
            // Linear cumulative approximation: cumulative = tick * secondsAgo
            // TWAP = (tickCumulative[now] - tickCumulative[ago]) / time
            if (secondsAgos[i] == 0) {
                tickCumulatives[i] = int56(int256(currentTick_) * int256(uint256(secondsAgo_)));
            } else {
                tickCumulatives[i] = int56(int256(pastTick_) * int256(uint256(secondsAgo_)));
            }
            secondsPerLiquidityCumulativeX128s[i] = 0; // mock only
        }
    }

    /// @notice Mock Uniswap V3 slot0
    function slot0()
        external
        view
        override
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        )
    {
        return (
            sqrtPriceX96_,
            currentTick_,
            0, // observationIndex
            1, // observationCardinality
            1, // observationCardinalityNext
            0, // feeProtocol
            true // unlocked
        );
    }

    /// --------------------
    /// Internal utilities
    /// --------------------

    /// @notice Convert price (token1 per token0) → sqrtPriceX96, taking decimals into account
    function _priceToSqrtPriceX96(uint256 price, uint8 decimalsToken0, uint8 decimalsToken1)
        internal
        pure
        returns (uint160)
    {
        // Adjust price by decimals difference
        uint256 scaledPrice = (price * (10 ** decimalsToken0)) / (10 ** decimalsToken1);
        // sqrt(scaledPrice) * 2^96
        uint256 sqrtPrice = _sqrt(scaledPrice) * (2 ** 96);
        require(sqrtPrice <= type(uint160).max, "sqrtPrice overflow");
        return uint160(sqrtPrice);
    }

    /// Babylonian method for square root
    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
