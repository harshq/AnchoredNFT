// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from "forge-std/Script.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {PlanetNFT} from "src/PlanetNFT.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";

contract MintAndList is Script, ERC721Holder {
    address nftAddress = DevOpsTools.get_most_recent_deployment("PlanetNFT", block.chainid);
    address marketplaceAddress = DevOpsTools.get_most_recent_deployment("NFTMarketplace", block.chainid);

    function run() external {
        vm.startBroadcast();
        uint256 tokenId = PlanetNFT(nftAddress).terraform();
        // uint256 tokenId2 = PlanetNFT(nftAddress).terraform();
        // uint256 tokenId3 = PlanetNFT(nftAddress).terraform();
        PlanetNFT(nftAddress).approve(marketplaceAddress, tokenId);

        NFTMarketplace(marketplaceAddress).listItem(nftAddress, tokenId, 1e6);
        vm.stopBroadcast();
    }
}
