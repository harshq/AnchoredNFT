// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IUniswapV3PoolMock} from "./UniswapV3PoolMock.sol";

contract UniswapV3PoolStaticMockETH is IUniswapV3PoolMock {
    // Hardcoded observe values for WETH/USDT (from cast call)
    int56[2] private tickCumulatives = [int56(-27268182882883), int56(-27268876273507)];

    uint160[2] private secondsPerLiquidityCumulativeX128 =
        [uint160(11464477412675948179306886368), uint160(11464557601658341296107542726)];

    // slot0 values for WETH/USDT (from cast call)
    uint160 private sqrtPriceX96 = 5261269445201335669764728;
    int24 private tick = -192404;
    uint16 private observationIndex = 76;
    uint16 private observationCardinality = 100;
    uint16 private observationCardinalityNext = 100;
    uint8 private feeProtocol = 0;
    bool private unlocked = true;

    address private immutable token0Address;
    address private immutable token1Address;

    constructor(address _token0, address _token1) {
        token0Address = _token0;
        token1Address = _token1;
    }

    function token0() public view returns (address) {
        return token0Address;
    }

    function token1() public view returns (address) {
        return token1Address;
    }

    function observe(uint32[] calldata /*secondsAgos*/ )
        external
        view
        returns (int56[] memory tickCumulatives_, uint160[] memory secondsPerLiquidityCumulativeX128_)
    {
        tickCumulatives_ = new int56[](2);
        tickCumulatives_[0] = tickCumulatives[0];
        tickCumulatives_[1] = tickCumulatives[1];

        secondsPerLiquidityCumulativeX128_ = new uint160[](2);
        secondsPerLiquidityCumulativeX128_[0] = secondsPerLiquidityCumulativeX128[0];
        secondsPerLiquidityCumulativeX128_[1] = secondsPerLiquidityCumulativeX128[1];
    }

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96_,
            int24 tick_,
            uint16 observationIndex_,
            uint16 observationCardinality_,
            uint16 observationCardinalityNext_,
            uint8 feeProtocol_,
            bool unlocked_
        )
    {
        return (
            sqrtPriceX96,
            tick,
            observationIndex,
            observationCardinality,
            observationCardinalityNext,
            feeProtocol,
            unlocked
        );
    }
}
