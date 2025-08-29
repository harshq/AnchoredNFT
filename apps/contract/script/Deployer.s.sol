// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from
    "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "chainlink-brownie-contracts/contracts/src/v0.8/mocks/MockLinkToken.sol";
import {MockV3Aggregator} from "chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {HelperConfig, Config, CodeConstants} from "script/HelperConfig.s.sol";
import {VRFInteractions} from "script/VRFInteractions.s.sol";
import {PlanetNFT} from "src/PlanetNFT.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";
import {NFTEngine} from "src/NFTEngine.sol";
import {VRFConfig, CollateralConfig} from "src/IEngine.sol";
import {Vault} from "src/Vault.sol";

contract Deployer is Script, CodeConstants {
    function run() public returns (PlanetNFT, NFTEngine, NFTMarketplace, Vault, Config memory) {
        HelperConfig helperConfig = new HelperConfig();
        Config memory config = helperConfig.getConfig();
        VRFInteractions vrfInteractions = new VRFInteractions();
        NFTEngine engine;
        PlanetNFT planetNFT;
        NFTMarketplace marketplace;
        Vault vault;

        // create and fund the VRF subscription
        if (config.vrfCoordinatorSubId == 0) {
            config.vrfCoordinatorSubId = vrfInteractions.createSubscription(config);
            vrfInteractions.fundSubscription(config);
        }

        vm.startBroadcast(config.account);

        vault = new Vault(config.collateralTokens);
        // deploy engine
        engine = new NFTEngine();
        // deploy NFT contract
        planetNFT = new PlanetNFT(
            address(vault),
            address(engine),
            VRFConfig({
                vrfCoordinator: config.vrfCoordinator,
                vrfCoordinatorSubId: config.vrfCoordinatorSubId,
                vrfKeyHash: config.vrfKeyHash,
                vrfGasLimit: config.vrfGasLimit
            }),
            CollateralConfig({
                pairs: config.collateralPairs,
                tokens: config.collateralTokens,
                priceFeeds: config.collateralPriceFeeds
            })
        );
        // transfer vault ownership to NFT contract
        vault.transferOwnership(address(planetNFT));

        // deploy marketplace with accepted token
        marketplace = new NFTMarketplace(config.paymentToken);
        vm.stopBroadcast();

        console.log("PlanetNFT is at", address(planetNFT));
        console.log("NFTMarketplace is at", address(marketplace));
        console.log("Vault is at", address(vault));
        console.log("NFTEngine is at", address(engine));

        // add consumer for VRF
        vrfInteractions.addConsumer(config, address(planetNFT));
        return (planetNFT, engine, marketplace, vault, config);
    }
}
