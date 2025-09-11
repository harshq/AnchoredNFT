// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {USDTMock} from "test/mock/USDTMock.sol";
import {WBTCMock} from "test/mock/WBTCMock.sol";
import {WETHMock} from "test/mock/WETHMock.sol";
import {VRFCoordinatorV2_5Mock} from
    "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "chainlink-brownie-contracts/contracts/src/v0.8/mocks/MockLinkToken.sol";
// import {MockV3Aggregator} from "chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";
// import {UniswapV3PoolMock} from "test/mock/UniswapV3PoolMock.sol";
import {UniswapV3PoolStaticMockBTC} from "test/mock/UniswapV3MockStaticBTC.sol";
import {UniswapV3PoolStaticMockETH} from "test/mock/UniswapV3MockStaticETH.sol";
import {Constants} from "src/Constants.sol";

struct Config {
    address account;
    address paymentToken;
    address linkToken;
    address vrfCoordinator;
    uint256 vrfCoordinatorSubId;
    bytes32 vrfKeyHash;
    uint32 vrfGasLimit;
    string[] collateralPairs;
    address[] collateralBases;
    address[] collateralTokens;
    address[] collateralUniswapV3Pools;
}

contract HelperConfig is Script {
    error HelperConfig__UnsupportedChainId(uint256 chainid);

    Config private s_anvilChainConfig;
    // address private s_originalSender;
    // mapping(uint256 chainId => Config config) private chainIdToConfig;

    function getConfig() public returns (Config memory) {
        if (block.chainid == Constants.ANVIL_CHAIN_ID) {
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

        WBTCMock wbtc;
        WETHMock weth;
        USDTMock usdt;
        MockLinkToken linkToken;
        VRFCoordinatorV2_5Mock vrfCoordinator;

        vm.startBroadcast();

        // mock btc pool
        wbtc = new WBTCMock();
        wbtc.mint(Constants.ANVIL_DEFAULT_ACCOUNT, 100 ether);
        // mock eth/usdt pool
        weth = new WETHMock();
        weth.mint(Constants.ANVIL_DEFAULT_ACCOUNT, 100 ether);

        usdt = new USDTMock();
        usdt.mint(Constants.ANVIL_DEFAULT_ACCOUNT, 1000e6);

        UniswapV3PoolStaticMockBTC btcUniswapV3PoolMock = new UniswapV3PoolStaticMockBTC(address(usdt), address(wbtc));
        UniswapV3PoolStaticMockETH ethUniswapV3PoolMock = new UniswapV3PoolStaticMockETH(address(usdt), address(weth));

        // other contract deployments
        linkToken = new MockLinkToken();
        vrfCoordinator = new VRFCoordinatorV2_5Mock(
            Constants.VRF_MOCK_BASE_FEE, Constants.VRF_MOCK_GAS_PRICE_LINK, Constants.VRF_MOCK_WEI_PER_UNIT_LINK
        );

        // other contract deployments
        linkToken = new MockLinkToken();
        vrfCoordinator =
            new VRFCoordinatorV2_5Mock(VRF_MOCK_BASE_FEE, VRF_MOCK_GAS_PRICE_LINK, VRF_MOCK_WEI_PER_UNIT_LINK);

        usdt = new USDTMock();
        usdt.mint(ANVIL_DEFAULT_ACCOUNT, 1000e6);

        vm.stopBroadcast();

        // collateral config
        string[] memory collateralPairs = new string[](2);
        collateralPairs[0] = "BTC/USD";
        collateralPairs[1] = "ETH/USD";

        address[] memory collateralBases = new address[](2);
        collateralBases[0] = address(usdt);
        collateralBases[1] = address(usdt);

        address[] memory collateralTokens = new address[](2);
        collateralTokens[0] = address(wbtc);
        collateralTokens[1] = address(weth);

        address[] memory collateralUniswapV3Pools = new address[](2);
        collateralUniswapV3Pools[0] = address(btcUniswapV3PoolMock);
        collateralUniswapV3Pools[1] = address(ethUniswapV3PoolMock);

        console.log("wBTC mock deployed at", address(wbtc));
        console.log("wETH mock deployed at", address(weth));
        console.log("USDT mock deployed at", address(usdt));
        console.log("LINK token mock deployed at", address(linkToken));
        console.log("VRFCoordinator deployed at", address(vrfCoordinator));

        s_anvilChainConfig = Config({
            account: Constants.ANVIL_DEFAULT_ACCOUNT,
            paymentToken: address(usdt),
            linkToken: address(linkToken),
            // vrf stuff
            vrfCoordinator: address(vrfCoordinator),
            vrfCoordinatorSubId: 0, // to be updated in VRFInteractions
            vrfKeyHash: 0x111122223333444455556666777788889999aaaabbbbccccddddeeeeffff0000,
            vrfGasLimit: 500_000,
            // collateral stuff
            collateralPairs: collateralPairs,
            collateralBases: collateralBases,
            collateralTokens: collateralTokens,
            collateralUniswapV3Pools: collateralUniswapV3Pools
        });

        return s_anvilChainConfig;
    }
}
