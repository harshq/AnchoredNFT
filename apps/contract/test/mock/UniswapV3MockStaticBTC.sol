// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IUniswapV3PoolMock} from "./UniswapV3PoolMock.sol";

contract UniswapV3PoolStaticMockBTC is IUniswapV3PoolMock {
    // Hardcoded values you gave
    int56[2] private tickCumulatives = [int56(8356142185379), int56(8356395165791)];

    uint160[2] private secondsPerLiquidityCumulativeX128 =
        [uint160(16717714725055701867222746942637496), uint160(16717737986390815413817228049005462)];

    // slot0 values
    uint160 private sqrtPriceX96 = 2643877446913706560595760873174;
    int24 private tick = 70156;
    uint16 private observationIndex = 40;
    uint16 private observationCardinality = 600;
    uint16 private observationCardinalityNext = 600;
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
