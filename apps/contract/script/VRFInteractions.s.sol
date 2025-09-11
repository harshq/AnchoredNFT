// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {Config} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from
    "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "chainlink-brownie-contracts/contracts/src/v0.8/mocks/MockLinkToken.sol";
import {Constants} from "src/Constants.sol";

contract VRFInteractions is Script {
    function createSubscription(Config calldata config) external returns (uint256 vrfCoordinatorSubId) {
        vm.startBroadcast(config.account);
        vrfCoordinatorSubId = VRFCoordinatorV2_5Mock(config.vrfCoordinator).createSubscription();
        vm.stopBroadcast();
    }

    function fundSubscription(Config calldata config) external {
        if (block.chainid == Constants.ANVIL_CHAIN_ID) {
            vm.startBroadcast(config.account);
            console.log("Funding VRF subscription ID:", config.vrfCoordinatorSubId);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).fundSubscription(
                config.vrfCoordinatorSubId, 10000000000 ether
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(config.account);
            MockLinkToken(config.linkToken).transferAndCall(
                config.vrfCoordinator, Constants.VRF_FUND_AMOUNT_LINK, abi.encode(config.vrfCoordinatorSubId)
            );
            vm.stopBroadcast();
        }
    }

    function addConsumer(Config calldata config, address contractToAddToVrf) external {
        vm.startBroadcast(config.account);
        VRFCoordinatorV2_5Mock(config.vrfCoordinator).addConsumer(config.vrfCoordinatorSubId, contractToAddToVrf);
        vm.stopBroadcast();
    }
}
