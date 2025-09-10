// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Test, console} from "forge-std/Test.sol";
import {TokenMetadata, CollateralTokenConfig} from "src/IEngine.sol";
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
        (nft, engine, marketplace, vault, config) = deployer.run();
    }

    function testGenerateSVG(uint256 tokenId) public {
        string memory svg = engine.generateWithMeta(
            tokenId,
            "122",
            config.collateralPairs[0],
            config.collateralBases[0],
            config.collateralTokens[0],
            config.collateralUniswapV3Pools[0],
            1e18 // 1 token in system
        );
        string memory path = "./test/out.svg";
        vm.writeFile(path, svg);
    }
}
