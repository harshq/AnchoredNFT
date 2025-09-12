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
    IEngine, TokenMetadata, CollateralTokenConfig, RequestParams, VRFConfig, CollateralConfig
} from "src/IEngine.sol";

/**
 * @title PlanetNFT v1
 * @author Harshana Abeyaratne
 *
 * A procedurally generated planet with random colors and rotation.
 *
 * @notice uses predictable randomness generator. To be
 * refactored to use Chainlink VRR.
 *
 */
contract PlanetNFT is ERC721, VRFConsumerBaseV2Plus {
    error PlanetNFT__InvalidVrfRequest(uint256 requestId);
    error PlanetNFT__NeedAtleastOnePricefeedPair();
    error PlanetNFT__UnsupportedCollateralToken(address token);
    error PlanetNFT__CollateralAmountMustBeMoreThanZero();
    error PlanetNFT__CollateralConfigLengthMismatch();
    error PlanetNFT__CollateralTransferFailed();
    error PlanetNFT__CallerMustBeTheOwner();
    error PlanetNFT__NoCollateralForToken();

    event PlanetRequested(
        uint256 indexed requestId,
        uint256 indexed tokenId,
        address collateralTokenAddress,
        uint256 collateralAmount,
        address indexed minter
    );
    event PlanetMinted(uint256 indexed requestId, uint256 indexed tokenId, address indexed minter);
    event PlanetDestroyed(uint256 indexed tokenId, address indexed owner);

    ////////////////////////////
    ///        STATE         ///
    ////////////////////////////
    uint256 private s_counter;
    address private immutable i_vault;
    address private immutable i_nftEngine;
    VRFConfig private i_vrfConfig;

    mapping(uint256 tokenId => TokenMetadata metadata) private s_tokenIdToMetadata;
    mapping(uint256 requestId => RequestParams sender) s_vrfRequestIdToRequestParams;
    mapping(address collateralAddress => CollateralTokenConfig collateralTokenConfig) i_collateralAddressToConfig;

    ////////////////////////////
    ///     CONSTRUCTOR      ///
    ////////////////////////////
    constructor(address vault, address nftEngine, VRFConfig memory vrfConfig, CollateralConfig memory collateralConfig)
        ERC721("PlanetNFT", "PNFT")
        VRFConsumerBaseV2Plus(vrfConfig.vrfCoordinator)
    {
        if (
            !(
                collateralConfig.pairs.length == collateralConfig.bases.length
                    && collateralConfig.bases.length == collateralConfig.tokens.length
                    && collateralConfig.tokens.length == collateralConfig.pools.length
            )
        ) {
            revert PlanetNFT__CollateralConfigLengthMismatch();
        }

        if (collateralConfig.pools.length == 0) {
            revert PlanetNFT__NeedAtleastOnePricefeedPair();
        }
        i_vault = vault;
        i_nftEngine = nftEngine;
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
     * Starts terraforming a new PlanetNFT. Initiated a VRF request
     * and emits a event with requestId and creator.
     *
     * @return vrfRequestId requestId for the Randomness
     */
    function terraform(address collateralTokenAddress, uint256 collateralAmount)
        external
        returns (uint256 vrfRequestId)
    {
        // Checks
        if (i_collateralAddressToConfig[collateralTokenAddress].token == address(0)) {
            revert PlanetNFT__UnsupportedCollateralToken(collateralTokenAddress);
        }

        if (collateralAmount == 0) {
            revert PlanetNFT__CollateralAmountMustBeMoreThanZero();
        }

        // Effects
        uint256 tokenId = s_counter;
        s_counter++;

        // Intractions
        IVault(i_vault).deposit(msg.sender, tokenId, collateralTokenAddress, collateralAmount);

        vrfRequestId = requestRandomWords();
        s_vrfRequestIdToRequestParams[vrfRequestId] = RequestParams({
            tokenId: tokenId,
            sender: msg.sender,
            collateralTokenAddress: collateralTokenAddress,
            timestamp: block.timestamp
        });

        emit PlanetRequested(vrfRequestId, tokenId, collateralTokenAddress, collateralAmount, msg.sender);
        return vrfRequestId;
    }

    function refundCollateral(uint256 tokenId, address collateralTokenAddress) external {
        IVault(i_vault).refund(tokenId, collateralTokenAddress);
    }

    function liquidate(uint256 tokenId, address collateralTokenAddress) external {
        address owner = ownerOf(tokenId);
        if (msg.sender != owner) {
            revert PlanetNFT__CallerMustBeTheOwner();
        }

        _burn(tokenId);
        IVault(i_vault).withdraw(owner, tokenId, collateralTokenAddress);
        emit PlanetDestroyed(tokenId, owner);
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
    function tokenURI(uint256 tokenId) public view override returns (string memory metadata) {
        _requireOwned(tokenId);

        (address[] memory collaterals, uint256[] memory amounts) = IVault(i_vault).balanceOf(tokenId);

        string memory svg = generateSVGForTokenId(tokenId, collaterals[0], amounts[0]);
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
                        '"description":"A procedurally generated planet that changes color with each glance.",',
                        '"image":"',
                        imageUri,
                        '",',
                        '"attributes":[{"collateral":"',
                        Strings.toHexString(collaterals[0]),
                        '","value":"',
                        Strings.toString(amounts[0]),
                        '"}]',
                        "}"
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
    function generateSVGForTokenId(uint256 tokenId, address, /* collateral */ uint256 amount)
        public
        view
        returns (string memory svg)
    {
        TokenMetadata memory metadata = s_tokenIdToMetadata[tokenId];
        CollateralTokenConfig memory collateralTokenConfig = i_collateralAddressToConfig[metadata.collateralAddress];

        return IEngine(i_nftEngine).generateWithMeta(
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
     */
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    /**
     * Chainlink VRF fulfillRandomWords
     *
     * @param requestId request id of the fulfilled request
     * @param randomWords random words
     */
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        RequestParams memory requestParams = s_vrfRequestIdToRequestParams[requestId];
        if (requestParams.sender == address(0)) {
            revert PlanetNFT__InvalidVrfRequest(requestId);
        }

        delete s_vrfRequestIdToRequestParams[requestId];

        bool hasDeposit = IVault(i_vault).hasDeposit(requestParams.tokenId, requestParams.collateralTokenAddress);
        if (!hasDeposit) {
            revert PlanetNFT__NoCollateralForToken();
        }

        s_tokenIdToMetadata[requestParams.tokenId] = TokenMetadata({
            base: Strings.toString(randomWords[0] % 360),
            collateralAddress: requestParams.collateralTokenAddress
        });

        _safeMint(requestParams.sender, requestParams.tokenId);
        IVault(i_vault).markMinted(requestParams.tokenId, requestParams.collateralTokenAddress);
        emit PlanetMinted(requestId, requestParams.tokenId, requestParams.sender);
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
