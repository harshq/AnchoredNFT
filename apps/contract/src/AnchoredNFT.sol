// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {VRFConsumerBaseV2Plus} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVault} from "src/IVault.sol";
import {Constants} from "src/Constants.sol";
import {
    EngineConfig,
    TokenMetadata,
    CollateralTokenConfig,
    RequestParams,
    VRFConfig,
    CollateralConfig
} from "src/Structs.sol";
import {IEngine} from "src/IEngine.sol";

/**
 * @title AnchoredNFT
 * @author Harshana Abeyaratne
 * @notice This contract implements a collateral-backed NFT system where NFTs (Anchored) are minted
 *         against user deposits of supported collateral tokens. Each NFT is procedurally generated
 *         by an external engine and anchored to its collateral value.
 *
 * @dev
 * - Integrates with Chainlink VRF v2+ for on-chain randomness used in NFT generation.
 * - Supports multiple pluggable engines (IEngine) for flexible NFT rendering and metadata logic.
 * - Uses a Vault contract (IVault) to manage collateral deposits, withdrawals, and refunding.
 * - Metadata (name, description, attributes) is constructed fully on-chain and returned as a
 *   Base64-encoded JSON data URI. SVG images are also generated and embedded in metadata.
 * - Owner (deployer) can add new engines and toggle engine availability via onlyOwner functions.
 *
 * Key Features:
 * - Collateral-backed NFTs: Each NFT is tied to collateral held in the Vault.
 * - Randomized generation: NFT metadata is seeded with Chainlink VRF randomness.
 * - Engine modularity: New engines can be deployed and plugged into the system.
 * - On-chain metadata & images: OpenSea and wallets can render NFTs directly from on-chain data.
 *
 * Errors:
 * - AnchoredNFT__InvalidVrfRequest: VRF request does not exist or was already fulfilled.
 * - AnchoredNFT__NeedAtleastOnePricefeedPair: Deployment must configure at least one price feed pair.
 * - AnchoredNFT__UnsupportedCollateralToken: Provided collateral is not supported by the system.
 * - AnchoredNFT__CollateralAmountMustBeMoreThanZero: Prevents zero-collateral mints.
 * - AnchoredNFT__CollateralConfigLengthMismatch: Input config arrays mismatch in length.
 * - AnchoredNFT__CollateralTransferFailed: Collateral transfer to Vault failed.
 * - AnchoredNFT__CallerMustBeTheOwner: Action restricted to the token/NFT owner.
 * - AnchoredNFT__NoCollateralForToken: No collateral associated with a given tokenId.
 * - AnchoredNFT__EngineNotFound: Provided engine is not registered in the system.
 * - AnchoredNFT__EngineNotAvailable: Provided engine exists but is currently paused.
 *
 * Events:
 * - NFTRequested: Emitted when a VRF request is initiated for a new NFT mint.
 * - NFTMinted: Emitted when a new NFT is successfully minted.
 * - NFTDestroyed: Emitted when an NFT is burned and collateral withdrawn.
 * - EngineAdded: Emitted when a new engine is added by the owner.
 * - EngineStateChanged: Emitted when an engine is paused or resumed.
 *
 * Security Considerations:
 * - Collateral is managed by a Vault contract, not stored directly in this contract.
 * - If Chainlink VRF fails or stalls, collateral may be locked until refund logic is triggered.
 * - Only the contract owner can manage engines, but collateral-related functions are permissionless.
 */
contract AnchoredNFT is ERC721, VRFConsumerBaseV2Plus {
    /////////////////////////////
    ///        ERRORS         ///
    /////////////////////////////
    error AnchoredNFT__InvalidVrfRequest(uint256 requestId);
    error AnchoredNFT__NeedAtleastOnePricefeedPair();
    error AnchoredNFT__UnsupportedCollateralToken(address token);
    error AnchoredNFT__CollateralAmountMustBeMoreThanZero();
    error AnchoredNFT__CollateralConfigLengthMismatch();
    error AnchoredNFT__CollateralTransferFailed();
    error AnchoredNFT__CallerMustBeTheOwner();
    error AnchoredNFT__NoCollateralForToken();
    error AnchoredNFT__EngineNotFound(address engine);
    error AnchoredNFT__EngineNotAvailable(address engine);

    event NFTRequested(
        uint256 indexed requestId,
        uint256 indexed tokenId,
        address collateralTokenAddress,
        uint256 collateralAmount,
        address indexed minter
    );
    event NFTMinted(uint256 indexed requestId, uint256 indexed tokenId, address indexed minter);
    event NFTDestroyed(uint256 indexed tokenId, address indexed owner);
    event EngineAdded(address indexed engine);
    event EngineStateChanged(address indexed engine, bool indexed newState);

    ////////////////////////////
    ///        STATE         ///
    ////////////////////////////
    uint256 private s_counter;
    address private immutable i_vault;
    VRFConfig private i_vrfConfig;

    address[] s_engines;
    mapping(uint256 tokenId => TokenMetadata metadata) private s_tokenIdToMetadata;
    mapping(uint256 requestId => RequestParams sender) s_vrfRequestIdToRequestParams;
    mapping(address collateralAddress => CollateralTokenConfig collateralTokenConfig) i_collateralAddressToConfig;
    mapping(address engine => EngineConfig engineConfig) i_engineToConfig;

    ////////////////////////////
    ///     CONSTRUCTOR      ///
    ////////////////////////////
    constructor(address vault, VRFConfig memory vrfConfig, CollateralConfig memory collateralConfig)
        ERC721("AnchoredNFT", "ANCR")
        VRFConsumerBaseV2Plus(vrfConfig.vrfCoordinator)
    {
        if (
            !(
                collateralConfig.pairs.length == collateralConfig.bases.length
                    && collateralConfig.bases.length == collateralConfig.tokens.length
                    && collateralConfig.tokens.length == collateralConfig.pools.length
            )
        ) {
            revert AnchoredNFT__CollateralConfigLengthMismatch();
        }

        if (collateralConfig.pools.length == 0) {
            revert AnchoredNFT__NeedAtleastOnePricefeedPair();
        }
        i_vault = vault;
        i_vrfConfig = vrfConfig;

        for (uint256 i = 0; i < collateralConfig.pairs.length; i++) {
            i_collateralAddressToConfig[collateralConfig.tokens[i]] = CollateralTokenConfig({
                pair: collateralConfig.pairs[i],
                base: collateralConfig.bases[i],
                token: collateralConfig.tokens[i],
                pool: collateralConfig.pools[i]
            });
        }
    }

    /////////////////////////////////
    ///    EXTERNAL FUNCTIONS     ///
    /////////////////////////////////

    /**
     * Configures the protocol to use a new engine
     *
     * @param engine address of the engine
     */
    function addEngine(address engine) external onlyOwner {
        s_engines.push(engine);
        i_engineToConfig[engine] = EngineConfig({engine: engine, addedOn: block.timestamp, paused: false});

        emit EngineAdded(engine);
    }

    /**
     * Pause/Resume engine
     *
     * @param engine address of the engine
     */
    function toggleEngine(address engine) external onlyOwner {
        bool state = i_engineToConfig[engine].paused;
        i_engineToConfig[engine].paused = !state;

        emit EngineStateChanged(engine, !state);
    }

    /**
     * Starts terraforming a new ANCR. Initiated a VRF request
     * and emits a event with requestId and creator.
     *
     * @return vrfRequestId requestId for the Randomness
     */
    function create(address engine, address collateralTokenAddress, uint256 collateralAmount)
        external
        returns (uint256 vrfRequestId)
    {
        // Checks
        if (i_engineToConfig[engine].engine == address(0)) {
            revert AnchoredNFT__EngineNotFound(engine);
        }

        if (i_engineToConfig[engine].paused) {
            revert AnchoredNFT__EngineNotAvailable(engine);
        }

        if (i_collateralAddressToConfig[collateralTokenAddress].token == address(0)) {
            revert AnchoredNFT__UnsupportedCollateralToken(collateralTokenAddress);
        }

        if (collateralAmount == 0) {
            revert AnchoredNFT__CollateralAmountMustBeMoreThanZero();
        }

        // Effects
        uint256 tokenId = s_counter;
        s_counter++;

        // Intractions
        IVault(i_vault).deposit(msg.sender, tokenId, collateralTokenAddress, collateralAmount);

        vrfRequestId = requestRandomWords();
        s_vrfRequestIdToRequestParams[vrfRequestId] = RequestParams({
            engine: engine,
            tokenId: tokenId,
            sender: msg.sender,
            collateralTokenAddress: collateralTokenAddress,
            timestamp: block.timestamp
        });

        emit NFTRequested(vrfRequestId, tokenId, collateralTokenAddress, collateralAmount, msg.sender);
        return vrfRequestId;
    }

    function refundCollateral(uint256 tokenId, address collateralTokenAddress) external {
        IVault(i_vault).refund(tokenId, collateralTokenAddress);
    }

    function destroy(uint256 tokenId, address collateralTokenAddress) external {
        address owner = ownerOf(tokenId);
        if (msg.sender != owner) {
            revert AnchoredNFT__CallerMustBeTheOwner();
        }

        _burn(tokenId);
        IVault(i_vault).withdraw(owner, tokenId, collateralTokenAddress);
        emit NFTDestroyed(tokenId, owner);
    }

    function balanceOf(uint256 tokenId)
        external
        view
        returns (address[] memory collaterals, uint256[] memory amounts)
    {
        return IVault(i_vault).balanceOf(tokenId);
    }

    /////////////////////////////////
    ///     PUBLIC FUNCTIONS      ///
    /////////////////////////////////

    /**
     * Returns a Base64 encoded token URI for the token id.
     *
     * @param tokenId token id of NFT
     * @return metadata metadata for NFT
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        TokenMetadata memory metadata = s_tokenIdToMetadata[tokenId];
        (address[] memory collaterals, uint256[] memory amounts) = IVault(i_vault).balanceOf(tokenId);

        string memory svg = generateSVGForTokenId(tokenId, metadata, collaterals[0], amounts[0]);
        string memory imageUri = svgToImageURI(svg);

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    abi.encodePacked(
                        "{",
                        '"name":"',
                        name(),
                        " #",
                        Strings.toString(tokenId),
                        '",',
                        '"description":"',
                        IEngine(metadata.engine).description(),
                        '","image":"',
                        imageUri,
                        '","attributes":[',
                        '{"trait_type":"Engine", "value":"',
                        IEngine(metadata.engine).name(),
                        '"},{"trait_type":"Synced Pair", "value":"',
                        i_collateralAddressToConfig[collaterals[0]].pair,
                        '"},{"trait_type":"Collateral Token", "value":"',
                        Strings.toHexString(collaterals[0]),
                        '"},{"trait_type":"Collateral Amount", "value":"',
                        Strings.toString(amounts[0]),
                        '"}]}'
                    )
                )
            )
        );
    }

    /**
     * Returns a generated SVG based on colors
     * initialised at the creation of NFT
     *
     * @param tokenId token id of the NFT
     * @return svg generated svg
     */
    function generateSVGForTokenId(
        uint256 tokenId,
        TokenMetadata memory metadata,
        address, /* collateral */
        uint256 amount
    ) private view returns (string memory svg) {
        CollateralTokenConfig memory collateralTokenConfig = i_collateralAddressToConfig[metadata.collateralAddress];
        return IEngine(metadata.engine).generateWithMeta(
            tokenId,
            metadata.base,
            collateralTokenConfig.pair,
            collateralTokenConfig.base,
            collateralTokenConfig.token,
            collateralTokenConfig.pool,
            amount
        );
    }

    /////////////////////////////////
    ///    INTERNAL FUNCTIONS     ///
    /////////////////////////////////

    /**
     * Converts the SVG to a Base64 encoded string.
     *
     * @param svg image svg generated
     */
    function svgToImageURI(string memory svg) internal pure returns (string memory) {
        string memory baseURI = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(svg));
        return string(abi.encodePacked(baseURI, svgBase64Encoded));
    }

    /**
     * BaseURI of the NFTs. We have the encoding
     * since our NFTs are Base64 encoded.
     *
     */
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    /**
     * Chainlink VRF fulfillRandomWords
     *
     * @param requestId request id of the fulfilled request
     * @param randomWords random words from VRF
     */
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        RequestParams memory requestParams = s_vrfRequestIdToRequestParams[requestId];
        if (requestParams.sender == address(0)) {
            revert AnchoredNFT__InvalidVrfRequest(requestId);
        }

        delete s_vrfRequestIdToRequestParams[requestId];

        bool hasDeposit = IVault(i_vault).hasDeposit(requestParams.tokenId, requestParams.collateralTokenAddress);
        if (!hasDeposit) {
            revert AnchoredNFT__NoCollateralForToken();
        }

        s_tokenIdToMetadata[requestParams.tokenId] = TokenMetadata({
            engine: requestParams.engine,
            base: Strings.toString(randomWords[0] % 360),
            collateralAddress: requestParams.collateralTokenAddress
        });

        _safeMint(requestParams.sender, requestParams.tokenId);
        IVault(i_vault).markMinted(requestParams.tokenId, requestParams.collateralTokenAddress);
        emit NFTMinted(requestId, requestParams.tokenId, requestParams.sender);
    }

    /////////////////////////////////
    ///     PRIVATE FUNCTIONS     ///
    /////////////////////////////////

    /**
     * Requests 2 random numbers from Chainlink VRF
     *
     * @return requestId VRF request id
     */
    function requestRandomWords() private returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_vrfConfig.vrfKeyHash,
                subId: i_vrfConfig.vrfCoordinatorSubId,
                requestConfirmations: Constants.VRF_REQ_CONFIRMATIONS,
                callbackGasLimit: i_vrfConfig.vrfGasLimit,
                numWords: Constants.VRF_RANDOM_WORDS_COUNT,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
    }
}
