// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "forge-std/Script.sol";
import {HelperConfig, Config} from "script/HelperConfig.s.sol";
import {VRFInteractions} from "script/VRFInteractions.s.sol";
import {AnchoredNFT} from "src/AnchoredNFT.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";
import {PlanetEngineV1} from "src/PlanetEngineV1.sol";
import {VRFConfig, CollateralConfig} from "src/Structs.sol";
import {Vault} from "src/Vault.sol";

contract Deployer is Script {
    function run() public returns (AnchoredNFT, PlanetEngineV1, NFTMarketplace, Vault, Config memory) {
        HelperConfig helperConfig = new HelperConfig();
        Config memory config = helperConfig.getConfig();
        VRFInteractions vrfInteractions = new VRFInteractions();
        PlanetEngineV1 engine;
        AnchoredNFT anchoredNFT;
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
        engine = new PlanetEngineV1();
        // deploy NFT contract
        anchoredNFT = new AnchoredNFT(
            address(vault),
            VRFConfig({
                vrfCoordinator: config.vrfCoordinator,
                vrfCoordinatorSubId: config.vrfCoordinatorSubId,
                vrfKeyHash: config.vrfKeyHash,
                vrfGasLimit: config.vrfGasLimit
            }),
            CollateralConfig({
                bases: config.collateralBases,
                pairs: config.collateralPairs,
                tokens: config.collateralTokens,
                pools: config.collateralUniswapV3Pools
            })
        );
        // add engine
        anchoredNFT.addEngine(address(engine));

        // transfer vault ownership to NFT contract
        vault.transferOwnership(address(anchoredNFT));

        // transfer engine ownership to NFT contract
        engine.transferOwnership(address(anchoredNFT));

        // deploy marketplace with accepted token
        marketplace = new NFTMarketplace(config.paymentToken);
        vm.stopBroadcast();

        // add consumer for VRF
        vrfInteractions.addConsumer(config, address(anchoredNFT));
        return (anchoredNFT, engine, marketplace, vault, config);
    }
}
