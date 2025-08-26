// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Test, console} from "forge-std/Test.sol";
import {TokenMetadata} from "src/IEngine.sol";
import {PlanetNFT} from "src/PlanetNFT.sol";
import {NFTEngine} from "src/NFTEngine.sol";
import {Vault} from "src/Vault.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";
import {Deployer} from "script/Deployer.s.sol";
import {Config} from "script/HelperConfig.s.sol";

contract PlanetNFTTest is Test {
    PlanetNFT nft;
    NFTEngine engine;
    NFTMarketplace marketplace;
    Config config;
    Deployer deployer;
    Vault vault;

    function setUp() public {
        deployer = new Deployer();
        (nft, engine, marketplace, vault) = deployer.run();
    }

    // function testGenerateSVG(uint256 tokenId) public {
    //     TokenMetadata memory meta = TokenMetadata({base: "122", linkedPair: "BTC/USD"});

    //     vm.prank(config.account);
    //     string memory svg = engine.generateWithMeta(meta, tokenId);
    //     string memory path = "./test/out.svg";
    //     vm.writeFile(path, svg);
    // }
}
