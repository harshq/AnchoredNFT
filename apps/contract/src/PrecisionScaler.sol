// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Constants} from "src/Constants.sol";

library PrecisionScaler {
    function normalizeToPrecision(uint256 value, uint256 currentPrecisionFactor, uint256 endPrecisionFactor)
        internal
        pure
        returns (uint256 normalizedValue)
    {
        if (currentPrecisionFactor == endPrecisionFactor) {
            return value;
        } else if (currentPrecisionFactor < endPrecisionFactor) {
            return value * (10 ** (endPrecisionFactor - currentPrecisionFactor));
        } else {
            return value / 10 ** (currentPrecisionFactor - endPrecisionFactor);
        }
    }

    function normalizeToPrecision(int256 value, uint256 currentPrecisionFactor, uint256 endPrecisionFactor)
        internal
        pure
        returns (int256)
    {
        if (currentPrecisionFactor == endPrecisionFactor) {
            return value;
        } else if (currentPrecisionFactor < endPrecisionFactor) {
            return value * int256(10 ** (endPrecisionFactor - currentPrecisionFactor));
        } else {
            return value / int256(10 ** (currentPrecisionFactor - endPrecisionFactor));
        }
    }

    function normalizeToSystemPrecision(uint256 value, uint256 currentPrecisionFactor)
        internal
        pure
        returns (uint256 normalizedValue)
    {
        return normalizeToPrecision(value, currentPrecisionFactor, Constants.DECIMALS);
    }
}
