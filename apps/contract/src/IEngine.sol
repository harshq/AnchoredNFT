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
}

struct CollateralConfig {
    string[] pairs;
    address[] tokens;
    address[] priceFeeds;
}

struct RequestParams {
    uint256 tokenId;
    address sender;
    address collateralTokenAddress;
    uint256 timestamp;
}

struct VRFConfig {
    address vrfCoordinator;
    uint256 vrfCoordinatorSubId;
    bytes32 vrfKeyHash;
    uint32 vrfGasLimit;
}

interface IEngine {
    function generateWithMeta(
        uint256 tokenId,
        string memory tokenBase,
        string memory collateralPair,
        address pricefeed,
        uint256 collateralAmount
    ) external pure returns (string memory);
}
