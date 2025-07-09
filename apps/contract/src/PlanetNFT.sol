// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IEngine, Meta} from "src/IEngine.sol";
import {console2} from "forge-std/console2.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {VRFConsumerBaseV2Plus} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

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

    event PlanetRequested(uint256 indexed requestId, address indexed minter);
    event PlanetMinted(uint256 indexed requestId, address indexed minter, uint256 indexed tokenId);

    ////////////////////////////
    ///        STATE         ///
    ////////////////////////////
    uint32 private constant VRF_RANDOM_WORDS_COUNT = 2;
    uint16 private constant VRF_REQ_CONFIRMATIONS = 3;

    uint256 private immutable i_vrfCoordinatorSubId;
    bytes32 private immutable i_vrfKeyHash;
    uint32 private immutable i_vrfGasLimit;
    address private immutable i_nftEngine;
    uint256 private s_counter;
    string[] private s_pricefeedPairs;

    mapping(uint256 => Meta) private s_tokenIdToMeta;
    mapping(uint256 requestId => address sender) s_vrfRequestIdToSender;

    ////////////////////////////
    ///     CONSTRUCTOR      ///
    ////////////////////////////
    constructor(
        address nftEngine,
        address vrfCoordinator,
        uint256 vrfCoordinatorSubId,
        bytes32 vrfKeyHash,
        uint32 vrfGasLimit,
        string[] memory pricefeedPairs
    ) ERC721("PlanetNFT", "PNFT") VRFConsumerBaseV2Plus(vrfCoordinator) {
        if (pricefeedPairs.length == 0) {
            revert PlanetNFT__NeedAtleastOnePricefeedPair();
        }
        i_vrfCoordinatorSubId = vrfCoordinatorSubId;
        i_vrfKeyHash = vrfKeyHash;
        i_vrfGasLimit = vrfGasLimit;
        i_nftEngine = nftEngine;
        s_pricefeedPairs = pricefeedPairs;
    }

    /////////////////////////////////
    ///    EXTERNAL FUNCTIONS     ///
    /////////////////////////////////

    /**
     * Starts terraforming a new PlanetNFT. Initiated a VRF request
     * and emits a event with requestId and creator.
     *
     * @return requestId VRF request id
     */
    function terraform() external returns (uint256 requestId) {
        uint256 vrfRequestId = requestRandomWords();
        s_vrfRequestIdToSender[vrfRequestId] = msg.sender;

        emit PlanetRequested(vrfRequestId, msg.sender);
        return vrfRequestId;
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

        string memory svg = generateSVGForTokenId(tokenId);
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
                        '"description":"A procedurally generated planet that changes color with each glance. Your personal cosmic mood ring.",',
                        '"image":"',
                        imageUri,
                        '",',
                        '"attributes":[{"trait_type":"Mood","value":"Happy"}]',
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
    function generateSVGForTokenId(uint256 tokenId) public view returns (string memory svg) {
        Meta memory meta = s_tokenIdToMeta[tokenId];
        return IEngine(i_nftEngine).generateWithMeta(meta, tokenId);
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
        address sender = s_vrfRequestIdToSender[requestId];
        if (sender == address(0)) {
            revert PlanetNFT__InvalidVrfRequest(requestId);
        }

        delete s_vrfRequestIdToSender[requestId];

        uint256 tokenId = s_counter;
        s_counter++;

        s_tokenIdToMeta[tokenId] = Meta({base: Strings.toString(randomWords[0] % 360), linkedPair: s_pricefeedPairs[0]});

        _safeMint(sender, tokenId);
        emit PlanetMinted(requestId, sender, tokenId);
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
                keyHash: i_vrfKeyHash,
                subId: i_vrfCoordinatorSubId,
                requestConfirmations: VRF_REQ_CONFIRMATIONS,
                callbackGasLimit: i_vrfGasLimit,
                numWords: VRF_RANDOM_WORDS_COUNT,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
    }
}
