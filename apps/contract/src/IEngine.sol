// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

struct TokenMetadata {
    string base;
    address collateralAddress;
}

struct CollateralTokenConfig {
    string pair;
    address token;
    address priceFeed;
    uint256 priceFeedPrecision;
}

interface IEngine {
    function generateWithMeta(
        TokenMetadata calldata metadata,
        CollateralTokenConfig calldata collateralTokenConfig,
        uint256 tokenId
    ) external pure returns (string memory);
}
