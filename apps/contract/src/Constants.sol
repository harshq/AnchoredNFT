// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

library Constants {
    uint8 internal constant DECIMALS = 18;
    uint256 internal constant PRECISION_FACTOR = 10 ** DECIMALS;
    uint256 internal constant PRICE_CHANGE_DURATION = 60 * 60; // 1 hour in seconds
}
