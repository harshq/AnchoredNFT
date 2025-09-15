// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Constants} from "src/Constants.sol";
import {AnchoredNFT} from "src/AnchoredNFT.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Liquidate is Script {
    address vault = DevOpsTools.get_most_recent_deployment("Vault", block.chainid);
    address weth = DevOpsTools.get_most_recent_deployment("WETHMock", block.chainid);
    address nftAddress = DevOpsTools.get_most_recent_deployment("AnchoredNFT", block.chainid);
    address coordinator = DevOpsTools.get_most_recent_deployment("VRFCoordinatorV2_5Mock", block.chainid);
    address marketplaceAddress = DevOpsTools.get_most_recent_deployment("NFTMarketplace", block.chainid);
    // address wethAddress = DevOpsTools.get_most_recent_deployment("WETHMock", block.chainid);

    uint256 constant TOKEN_ID = 1;
    address constant OWNER = Constants.ANVIL_DEFAULT_ACCOUNT;

    function run() public {
        vm.startBroadcast(OWNER);

        uint256 startingBalance = IERC20(weth).balanceOf(OWNER);
        console.log("startingBalance", startingBalance);

        AnchoredNFT(nftAddress).destroy(TOKEN_ID, weth);

        uint256 endingBalance = IERC20(weth).balanceOf(OWNER);
        console.log("endingBalance", endingBalance);

        vm.stopBroadcast();
    }
}
