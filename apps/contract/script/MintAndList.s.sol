// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Script, console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {PlanetNFT} from "src/PlanetNFT.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";
import {VRFCoordinatorV2_5Mock} from
    "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {HelperConfig, Config, CodeConstants} from "script/HelperConfig.s.sol";

contract MintAndList is Script, CodeConstants {
    address vault = DevOpsTools.get_most_recent_deployment("Vault", block.chainid);
    address weth = DevOpsTools.get_most_recent_deployment("WETHMock", block.chainid);
    address nftAddress = DevOpsTools.get_most_recent_deployment("PlanetNFT", block.chainid);
    address coordinator = DevOpsTools.get_most_recent_deployment("VRFCoordinatorV2_5Mock", block.chainid);
    address marketplaceAddress = DevOpsTools.get_most_recent_deployment("NFTMarketplace", block.chainid);

    function run() external {
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);

        IERC20(weth).approve(vault, 1e18);

        uint256 requestId = PlanetNFT(nftAddress).terraform(weth, 1e18);
        vm.stopBroadcast();

        uint256[] memory randomWords = new uint256[](uint256(VRF_RANDOM_WORDS_COUNT));
        randomWords[0] = uint256(keccak256(abi.encode(block.number, block.timestamp, requestId, 0))); // base color hue
        randomWords[1] = uint256(keccak256(abi.encode(block.number, block.timestamp, requestId, 1))); // ring color hue

        vm.startBroadcast();
        vm.recordLogs();
        VRFCoordinatorV2_5Mock(coordinator).fulfillRandomWordsWithOverride(requestId, address(nftAddress), randomWords);
        vm.stopBroadcast();

        uint256 tokenId;

        Vm.Log[] memory logs = vm.getRecordedLogs();
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics.length > 0) {
                if (PlanetNFT.PlanetMinted.selector == logs[i].topics[0]) {
                    console2.log("Plant Minted event!");
                    tokenId = uint256(logs[i].topics[2]);
                    console2.log("TOKENID", tokenId);
                }
            }
        }

        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);

        PlanetNFT(nftAddress).approve(marketplaceAddress, tokenId);
        NFTMarketplace(marketplaceAddress).listItem(nftAddress, tokenId, 1e6);

        vm.stopBroadcast();
    }
}
