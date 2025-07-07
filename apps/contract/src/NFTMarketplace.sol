// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title NFTMarketplace v1
 * @author Harshana Abeyaratne
 *
 * A basic marketplace for selling NFTs with a 1% commission rate.
 *
 * @notice to be refactored to support adjustable commission rates.
 *
 */
contract NFTMarketplace is Ownable, ReentrancyGuard {
    ////////////////////////////
    ///       TYPE DEC       ///
    ////////////////////////////
    using SafeERC20 for IERC20;

    struct Listing {
        address seller;
        uint256 price;
    }

    ////////////////////////////
    ///        EVENTS        ///
    ////////////////////////////

    event ItemListed(address indexed tokenAddress, uint256 indexed tokenId);
    event ItemDelisted(address indexed tokenAddress, uint256 indexed tokenId);
    event ItemSold(address indexed tokenAddress, uint256 indexed tokenId, address indexed buyer);

    ////////////////////////////
    ///        ERRORS        ///
    ////////////////////////////
    error NFTMarketplace__PriceMustBeAboveZero();
    error NFTMarketplace__NotApprovedForMarketplace();
    error NFTMarketplace__NotOwner(address nftAddress, uint256 tokenId);
    error NFTMarketplace__NotListed(address nftAddress, uint256 tokenId);
    error NFTMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
    error NFTMarketplace__NotApprovedToTransfer(address nftAddress, uint256 tokenId);

    ////////////////////////////
    ///        STATE        ///
    ////////////////////////////
    uint256 private s_commission;
    uint256 private constant COMMISSION_BASIS_POINTS = 100; // 1% commission
    IERC20 private immutable i_paymentToken;

    mapping(address nftAddress => mapping(uint256 tokenId => Listing listing)) private s_listing;
    mapping(address owner => uint256 amount) private s_proceeds;

    ////////////////////////////
    ///       MODIFIERS      ///
    ////////////////////////////

    /**
     * Ensures the caller is the owner of the specified token.
     *
     * @param nftAddress address of the NFT contract
     * @param tokenId tokenId of the NFT
     *
     */
    modifier onlyOwnerOf(address nftAddress, uint256 tokenId) {
        if (IERC721(nftAddress).ownerOf(tokenId) != msg.sender) {
            revert NFTMarketplace__NotOwner(nftAddress, tokenId);
        }
        _;
    }

    /**
     * Ensures the NFT is currently listed for sale.
     *
     * @param nftAddress address of the NFT contract
     * @param tokenId tokenId of the NFT
     *
     */
    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listing[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert NFTMarketplace__NotListed(nftAddress, tokenId);
        }
        _;
    }

    /**
     * Ensures the NFT is not already listed for sale.
     *
     * @param nftAddress address of the NFT contract
     * @param tokenId tokenId of the NFT
     *
     */
    modifier notListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listing[nftAddress][tokenId];
        if (listing.seller != address(0)) {
            revert NFTMarketplace__AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    /**
     * Ensures this contract is approved to transfer the NFT.
     *
     * @param nftAddress address of the NFT contract
     * @param tokenId tokenId of the NFT
     *
     */
    modifier isApprovedByOwner(address nftAddress, uint256 tokenId, address owner) {
        IERC721 nft = IERC721(nftAddress);
        // Listing memory listing = s_listing[nftAddress][tokenId];

        if (
            nft.ownerOf(tokenId) != owner
                || !(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(owner, address(this)))
        ) {
            revert NFTMarketplace__NotApprovedToTransfer(nftAddress, tokenId);
        }
        _;
    }

    ////////////////////////////
    ///      CONSTRUCTOR     ///
    ////////////////////////////

    /**
     * Initializes the contract and sets the deployer as the owner.
     *
     * @param paymentToken accepted payment token for the marketplace
     *
     */
    constructor(address paymentToken) Ownable(msg.sender) {
        i_paymentToken = IERC20(paymentToken);
    }

    ////////////////////////////
    ///  EXTERNAL FUNCTIONS  ///
    ////////////////////////////

    /**
     * Lists an NFT for sale in the marketplace.
     *
     * @param nftAddress address of the NFT contract
     * @param tokenId tokenId of the NFT
     * @param price price of the NFT
     *
     */
    function listItem(address nftAddress, uint256 tokenId, uint256 price)
        external
        onlyOwnerOf(nftAddress, tokenId)
        notListed(nftAddress, tokenId)
        isApprovedByOwner(nftAddress, tokenId, msg.sender)
        nonReentrant
    {
        if (price == 0) {
            revert NFTMarketplace__PriceMustBeAboveZero();
        }

        emit ItemListed(nftAddress, tokenId);
        s_listing[nftAddress][tokenId] = Listing({seller: msg.sender, price: price});
    }

    /**
     * Cancels and removes an existing listing from the marketplace.
     *
     * @param nftAddress address of the NFT contract
     * @param tokenId tokenId of the NFT
     */
    function cancelListing(address nftAddress, uint256 tokenId)
        external
        onlyOwnerOf(nftAddress, tokenId)
        isListed(nftAddress, tokenId)
    {
        emit ItemDelisted(nftAddress, tokenId);
        delete s_listing[nftAddress][tokenId];
    }

    /**
     * Allows a user to purchase a listed NFT.
     * Proceeds are automatically transferred to the seller after deducting the marketplace fee.
     *
     * @param nftAddress address of the NFT contract
     * @param tokenId tokenId of the NFT
     *
     */
    function buyItem(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
        isApprovedByOwner(nftAddress, tokenId, s_listing[nftAddress][tokenId].seller)
        nonReentrant
    {
        IERC721 nft = IERC721(nftAddress);
        Listing memory listing = s_listing[nftAddress][tokenId];

        delete s_listing[nftAddress][tokenId];

        uint256 fee = listing.price * COMMISSION_BASIS_POINTS / 10_000;
        s_commission += fee;
        uint256 sellerAmount = listing.price - fee;
        s_proceeds[listing.seller] += sellerAmount;

        i_paymentToken.safeTransferFrom(msg.sender, address(this), listing.price);
        nft.safeTransferFrom(listing.seller, msg.sender, tokenId);
        i_paymentToken.safeTransfer(listing.seller, sellerAmount);

        emit ItemSold(nftAddress, tokenId, msg.sender);
    }

    /**
     * Allows owner of the marketplace to withdraw funds
     */
    function withdrawCommission() external onlyOwner nonReentrant {
        uint256 commission = s_commission;
        s_commission = 0;
        i_paymentToken.safeTransfer(payable(owner()), commission);
    }
}
