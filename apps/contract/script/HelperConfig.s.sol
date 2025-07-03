// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {MockUSDT} from "test/mock/MockUSDT.t.sol";

contract HelperConfig is Script {
    struct Config {
        address paymentToken;
    }

    error HelperConfig__UnsupportedChainId(uint256 chainid);

    uint256 private constant ANVIL_CHAIN_ID = 31337;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    Config private s_anvilChainConfig;
    address private s_originalSender;
    // mapping(uint256 chainId => Config config) private chainIdToConfig;

    constructor(address originalSender) {
        s_originalSender = originalSender;
    }

    function getConfig() public returns (Config memory) {
        if (block.chainid == ANVIL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        } else if (block.chainid == SEPOLIA_CHAIN_ID) {
            return getSepoliaConfig();
        } else {
            revert HelperConfig__UnsupportedChainId(block.chainid);
        }
    }

    function getSepoliaConfig() internal pure returns (Config memory) {
        return Config({paymentToken: 0x7169D38820dfd117C3FA1f22a697dBA58d90BA06});
    }

    function getOrCreateAnvilConfig() internal returns (Config memory) {
        if (s_anvilChainConfig.paymentToken != address(0)) {
            return s_anvilChainConfig;
        }

        MockUSDT usdt;

        vm.startBroadcast();
        usdt = new MockUSDT();
        usdt.mint(s_originalSender, 1000e6);
        vm.stopBroadcast();

        console.log("USDT mock deployed at", address(usdt));

        s_anvilChainConfig = Config({paymentToken: address(usdt)});
        return s_anvilChainConfig;
    }
}
