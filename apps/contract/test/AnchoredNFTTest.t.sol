// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Test} from "forge-std/Test.sol";
import {AnchoredNFT} from "src/AnchoredNFT.sol";
import {PlanetEngineV1} from "src/PlanetEngineV1.sol";
import {Vault} from "src/Vault.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";
import {Deployer} from "script/Deployer.s.sol";
import {Config} from "script/HelperConfig.s.sol";

contract PlanetNFTTest is Test {
    AnchoredNFT nft;
    PlanetEngineV1 engine;
    NFTMarketplace marketplace;
    Config config;
    Deployer deployer;
    Vault vault;

    function setUp() public {
        deployer = new Deployer();
        (nft, engine, marketplace, vault, config) = deployer.run();
    }

    function testGenerateSVG(uint256 tokenId, uint256 color) public {
        vm.startPrank(address(nft));
        string memory svg = engine.generateWithMeta(
            tokenId,
            Strings.toString(color % 360),
            config.collateralPairs[1],
            config.collateralBases[1],
            config.collateralTokens[1],
            config.collateralUniswapV3Pools[1],
            1e18 // 1 token in system
        );
        vm.stopPrank();
        string memory path = "./test/out.svg";
        vm.writeFile(path, svg);
    }
}
