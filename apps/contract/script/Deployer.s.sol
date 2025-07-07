// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from
    "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "chainlink-brownie-contracts/contracts/src/v0.8/mocks/MockLinkToken.sol";
import {HelperConfig, Config, CodeConstants} from "script/HelperConfig.s.sol";
import {VRFInteractions} from "script/VRFInteractions.s.sol";
import {PlanetNFT} from "src/PlanetNFT.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";
import {NFTEngine} from "src/NFTEngine.sol";

contract Deployer is Script, CodeConstants {
    function run() public returns (PlanetNFT, NFTMarketplace) {
        HelperConfig helperConfig = new HelperConfig();
        Config memory config = helperConfig.getConfig();
        VRFInteractions vrfInteractions = new VRFInteractions();
        NFTEngine engine;
        PlanetNFT planetNFT;
        NFTMarketplace marketplace;

        // create and fund the VRF subscription
        if (config.vrfCoordinatorSubId == 0) {
            config.vrfCoordinatorSubId = vrfInteractions.createSubscription(config);
            vrfInteractions.fundSubscription(config);
        }

        vm.startBroadcast(config.account);
        // deploy engine
        engine = new NFTEngine();
        // deploy NFT contract
        planetNFT = new PlanetNFT(
            address(engine),
            address(config.vrfCoordinator),
            config.vrfCoordinatorSubId,
            config.vrfKeyHash,
            config.vrfGasLimit
        );
        // transfer engine ownership to NFT contract
        engine.transferOwnership(address(planetNFT));

        // deploy marketplace with accepted token
        marketplace = new NFTMarketplace(config.paymentToken);
        vm.stopBroadcast();

        console.log("PlanetNFT is at", address(planetNFT));
        console.log("NFTMarketplace is at", address(marketplace));

        // add consumer for VRF
        vrfInteractions.addConsumer(config, address(planetNFT));
        return (planetNFT, marketplace);
    }
}
