// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {PlanetNFT} from "src/PlanetNFT.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";
import {Deployer} from "script/Deployer.s.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract PlanetNFTTest is Test {
    PlanetNFT nft;
    NFTMarketplace marketplace;
    Deployer deployer;

    function setUp() public {
        deployer = new Deployer();
        (nft, marketplace) = deployer.run();
    }

    function testGenerateSVG(uint256 tokenId) public {
        string memory svg = nft.generateSVGForTokenId(tokenId);
        string memory path = "./test/out.svg";
        vm.writeFile(path, svg);
    }

    // function testGetRandomNumber(uint256 tokenId) public view {
    //     console.log(nft.getRandomNumber(tokenId));
    // }
}
