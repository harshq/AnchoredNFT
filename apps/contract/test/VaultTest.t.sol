// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Constants} from "src/Constants.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Test, console} from "forge-std/Test.sol";
import {AnchoredNFT} from "src/AnchoredNFT.sol";
import {PlanetEngineV1} from "src/PlanetEngineV1.sol";
import {Vault} from "src/Vault.sol";
import {NFTMarketplace} from "src/NFTMarketplace.sol";
import {Deployer} from "script/Deployer.s.sol";
import {Config} from "script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {PrecisionScaler} from "src/PrecisionScaler.sol";

contract VaultText is Test {
    AnchoredNFT nft;
    PlanetEngineV1 engine;
    NFTMarketplace marketplace;
    Config config;
    Deployer deployer;
    Vault vault;

    address USER = makeAddr("user");

    function setUp() public {
        deployer = new Deployer();
        (nft, engine, marketplace, vault, config) = deployer.run();
    }

    function testBalanceOf() public {
        uint256 tokenId = 1;

        vm.prank(config.account);
        IERC20(config.collateralTokens[1]).approve(address(vault), 1e18);

        vm.startPrank(address(nft));
        (address[] memory startCollaterals, uint256[] memory startAmounts, uint256[] memory startDecimals) =
            vault.balanceOf(tokenId);

        vault.deposit(config.account, tokenId, config.collateralTokens[1], 1e18);
        vault.markMinted(tokenId, config.collateralTokens[1]);

        (address[] memory endCollaterals, uint256[] memory endAmounts, uint256[] memory endDecimals) =
            vault.balanceOf(tokenId);

        console.log(PrecisionScaler.normalizeToPrecision(endAmounts[0], Constants.DECIMALS, 8));
        vm.stopPrank();
    }
}
