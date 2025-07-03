// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {PlanetNFT} from "src/PlanetNFT.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";

contract Deployer is Script {
    function run() public returns (PlanetNFT, NFTMarketplace) {
        HelperConfig helperConfig = new HelperConfig(msg.sender);
        HelperConfig.Config memory config = helperConfig.getConfig();
        PlanetNFT planetNFT;
        NFTMarketplace marketplace;

        vm.startBroadcast();

        planetNFT = new PlanetNFT();
        marketplace = new NFTMarketplace(config.paymentToken);

        vm.stopBroadcast();

        console.log("PlanetNFT is at", address(planetNFT));
        console.log("NFTMarketplace is at", address(marketplace));

        return (planetNFT, marketplace);
    }
}
