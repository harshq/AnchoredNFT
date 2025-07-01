// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PlanetNFT} from "src/PlanetNFT.sol";

contract Deployer is Script {
    function setUp() public {}

    function run() public returns (PlanetNFT) {
        PlanetNFT planetNFT;
        vm.startBroadcast();
        planetNFT = new PlanetNFT();
        vm.stopBroadcast();

        return planetNFT;
    }
}
