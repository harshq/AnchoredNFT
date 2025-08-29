// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {USDTMock} from "test/mock/USDTMock.sol";
import {WBTCMock} from "test/mock/WBTCMock.sol";
import {WETHMock} from "test/mock/WETHMock.sol";
import {VRFCoordinatorV2_5Mock} from
    "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "chainlink-brownie-contracts/contracts/src/v0.8/mocks/MockLinkToken.sol";
import {MockV3Aggregator} from "chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";

struct Config {
    address account;
    address paymentToken;
    address linkToken;
    address vrfCoordinator;
    uint256 vrfCoordinatorSubId;
    bytes32 vrfKeyHash;
    uint32 vrfGasLimit;
    string[] collateralPairs;
    address[] collateralTokens;
    address[] collateralPriceFeeds;
}

contract CodeConstants {
    uint256 public constant ANVIL_CHAIN_ID = 31337;
    address public constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    uint96 public constant VRF_MOCK_BASE_FEE = 0.25 ether;
    uint96 public constant VRF_MOCK_GAS_PRICE_LINK = 1e9;
    int256 public constant VRF_MOCK_WEI_PER_UNIT_LINK = 4e15;
    uint256 public constant VRF_FUND_AMOUNT_LINK = 500 ether; // 500 link
    uint32 public constant VRF_RANDOM_WORDS_COUNT = 2;
}

contract HelperConfig is Script, CodeConstants {
    error HelperConfig__UnsupportedChainId(uint256 chainid);

    Config private s_anvilChainConfig;
    // address private s_originalSender;
    // mapping(uint256 chainId => Config config) private chainIdToConfig;

    function getConfig() public returns (Config memory) {
        if (block.chainid == ANVIL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        }
        //  else if (block.chainid == SEPOLIA_CHAIN_ID) {
        //     return getSepoliaConfig();
        // }
        else {
            revert HelperConfig__UnsupportedChainId(block.chainid);
        }
    }

    // function getSepoliaConfig() internal pure returns (Config memory) {
    //     return Config({paymentToken: 0x7169D38820dfd117C3FA1f22a697dBA58d90BA06});
    // }

    function getOrCreateAnvilConfig() internal returns (Config memory) {
        if (s_anvilChainConfig.paymentToken != address(0)) {
            return s_anvilChainConfig;
        }

        WETHMock weth;
        WBTCMock wbtc;
        USDTMock usdt;
        MockLinkToken linkToken;
        VRFCoordinatorV2_5Mock vrfCoordinator;

        vm.startBroadcast();
        // mock btc aggregator
        MockV3Aggregator btcMockAggregator = new MockV3Aggregator(8, 10e8);
        btcMockAggregator.updateRoundData(11, 10e8, (block.timestamp - 1 days), (block.timestamp - 1 days)); // day older
        btcMockAggregator.updateRoundData(12, 9.8e8, block.timestamp, block.timestamp); // latest
        wbtc = new WBTCMock();
        wbtc.mint(ANVIL_DEFAULT_ACCOUNT, 100 ether);

        // // mock eth aggregator
        MockV3Aggregator ethMockAggregator = new MockV3Aggregator(18, 4e18);
        ethMockAggregator.updateRoundData(11, 4.4e18, (block.timestamp - 1 days), (block.timestamp - 1 days)); // day older
        ethMockAggregator.updateRoundData(12, 4.5e18, block.timestamp, block.timestamp); // latest
        weth = new WETHMock();
        weth.mint(ANVIL_DEFAULT_ACCOUNT, 100 ether);

        vm.stopBroadcast();

        // collateral config
        string[] memory collateralPairs = new string[](2);
        collateralPairs[0] = "BTC/USD";
        collateralPairs[1] = "ETH/USD";

        address[] memory collateralTokens = new address[](2);
        collateralTokens[0] = address(wbtc);
        collateralTokens[1] = address(weth);

        address[] memory collateralPriceFeeds = new address[](2);
        collateralPriceFeeds[0] = address(btcMockAggregator);
        collateralPriceFeeds[1] = address(ethMockAggregator);

        vm.startBroadcast();

        linkToken = new MockLinkToken();
        vrfCoordinator =
            new VRFCoordinatorV2_5Mock(VRF_MOCK_BASE_FEE, VRF_MOCK_GAS_PRICE_LINK, VRF_MOCK_WEI_PER_UNIT_LINK);

        usdt = new USDTMock();
        usdt.mint(ANVIL_DEFAULT_ACCOUNT, 1000e6);
        vm.stopBroadcast();

        console.log("wBTC mock deployed at", address(wbtc));
        console.log("wETH mock deployed at", address(weth));
        console.log("USDT mock deployed at", address(usdt));
        console.log("LINK token mock deployed at", address(linkToken));
        console.log("VRFCoordinator deployed at", address(vrfCoordinator));

        s_anvilChainConfig = Config({
            account: ANVIL_DEFAULT_ACCOUNT,
            paymentToken: address(usdt),
            linkToken: address(linkToken),
            // vrf stuff
            vrfCoordinator: address(vrfCoordinator),
            vrfCoordinatorSubId: 0, // to be updated in VRFInteractions
            vrfKeyHash: 0x111122223333444455556666777788889999aaaabbbbccccddddeeeeffff0000,
            vrfGasLimit: 500_000,
            // collateral stuff
            collateralPairs: collateralPairs,
            collateralTokens: collateralTokens,
            collateralPriceFeeds: collateralPriceFeeds
        });

        return s_anvilChainConfig;
    }
}
