// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

library Constants {
    // system
    uint8 public constant DECIMALS = 18;
    uint256 public constant PRECISION_FACTOR = 10 ** DECIMALS;
    uint256 public constant PRICE_CHANGE_DURATION = 60 * 60; // 1 hour in seconds
    // anvil config
    address public constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    // VRF config
    uint96 public constant VRF_MOCK_BASE_FEE = 0.25 ether;
    uint96 public constant VRF_MOCK_GAS_PRICE_LINK = 1e9;
    int256 public constant VRF_MOCK_WEI_PER_UNIT_LINK = 4e15;
    uint256 public constant VRF_FUND_AMOUNT_LINK = 500 ether; // 500 link
    uint32 public constant VRF_RANDOM_WORDS_COUNT = 2;
    // chainids
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ANVIL_CHAIN_ID = 31337;
}
