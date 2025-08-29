// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

abstract contract CodeConstants {
    uint8 internal constant PRECISION_FACTOR = 18;
    uint256 internal constant PRECISION = 10 ** PRECISION_FACTOR;
}
