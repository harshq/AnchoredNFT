// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

struct TokenMetadata {
    string base;
    address collateralAddress;
}

struct CollateralTokenConfig {
    string pair;
    address base;
    address token;
    address pool;
}

struct CollateralConfig {
    string[] pairs;
    address[] bases;
    address[] tokens;
    address[] pools;
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
        address collateralBase,
        address collateralToken,
        address collateralPool,
        uint256 collateralAmount
    ) external pure returns (string memory);

    function description() external pure returns (string memory);
}
