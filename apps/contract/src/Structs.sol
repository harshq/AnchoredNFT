// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

struct TokenMetadata {
    string base;
    address collateralAddress;
    address engine;
}

struct EngineConfig {
    address engine;
    uint256 addedOn;
    bool paused;
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
    address engine;
}

struct VRFConfig {
    address vrfCoordinator;
    uint256 vrfCoordinatorSubId;
    bytes32 vrfKeyHash;
    uint32 vrfGasLimit;
}
