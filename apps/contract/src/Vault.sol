// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {PrecisionScaler} from "src/PrecisionScaler.sol";
import {Constants} from "src/Constants.sol";
import {CollateralPosition} from "src/Structs.sol";

/**
 * @title Vault
 * @author Harshana Abeyaratne
 * @notice Custodian contract that holds collateral deposits for NFT minting.
 * @dev This contract is fully controlled by the parent NFT engine/factory contract.
 *      - Users cannot interact directly.
 *      - Owner (engine contract) deposits, refunds, or withdraws collateral.
 *      - Collateral is normalized to system precision on deposit and back to token precision on withdrawal.
 */
contract Vault is Ownable, ReentrancyGuard {
    /////////////////////////////
    ///        ERRORS         ///
    /////////////////////////////
    error Vault__InvalidCollateralToken(address token);
    error Vault__CollateralAmountMustBeMoreThanZero();
    error Vault__CollateralUnsupported(address token);
    error Vault__CollateralWithdrawalFailed();
    error Vault__CollateralDepositFailed();
    error Vault__MintedTokensAreNotRefundable();
    error Vault__TokenMintPending();
    error Vault__CollateralDepositLockedPeriod(uint256 unlockTime);

    event DepositMade(
        address indexed depositor, address indexed collateral, uint256 indexed tokenId, uint256 rawDepositAmount
    );
    event CollateralMinted(uint256 indexed tokenId, address indexed collateral);
    event CollateralRefunded(
        uint256 indexed tokenId, address indexed beneficiary, address indexed collateral, uint256 rawDepositAmount
    );
    event CollateralWithdrawn(
        uint256 indexed tokenId, address indexed beneficiary, address indexed collateral, uint256 amount
    );

    ////////////////////////////
    ///        STATE         ///
    ////////////////////////////
    address[] private s_supportedCollaterals;
    mapping(uint256 tokenId => mapping(address collateralTokenAddress => CollateralPosition collateral)) private
        s_tokenIdToCollateral;

    ////////////////////////////
    ///     CONSTRUCTOR      ///
    ////////////////////////////
    constructor(address[] memory supportedCollaterals) Ownable(msg.sender) {
        s_supportedCollaterals = supportedCollaterals;
    }

    /////////////////////////////////
    ///    EXTERNAL FUNCTIONS     ///
    /////////////////////////////////

    /**
     * @notice Deposit collateral on behalf of a depositor for a given tokenId.
     * @dev Can only be called by the owner (engine contract).
     * @param depositor Address funding the collateral.
     * @param tokenId NFT tokenId linked to this collateral.
     * @param collateralTokenAddress Address of collateral token.
     * @param rawDepositAmount Amount deposited (in token precision).
     */
    function deposit(address depositor, uint256 tokenId, address collateralTokenAddress, uint256 rawDepositAmount)
        external
        payable
        onlyOwner
        nonReentrant
    {
        if (rawDepositAmount == 0) {
            revert Vault__CollateralAmountMustBeMoreThanZero();
        }
        if (!supportedCollateral(collateralTokenAddress)) {
            revert Vault__CollateralUnsupported(collateralTokenAddress);
        }

        CollateralPosition storage pos = s_tokenIdToCollateral[tokenId][collateralTokenAddress];
        pos.amount += PrecisionScaler.normalizeToSystemPrecision(
            rawDepositAmount, IERC20Metadata(collateralTokenAddress).decimals()
        );
        pos.depositor = depositor;
        pos.minted = false;
        pos.timestamp = block.timestamp;

        bool success = SafeERC20.trySafeTransferFrom(
            IERC20Metadata(collateralTokenAddress), depositor, address(this), rawDepositAmount
        );
        if (!success) revert Vault__CollateralDepositFailed();

        emit DepositMade(depositor, collateralTokenAddress, tokenId, rawDepositAmount);
    }

    /**
     * @notice Mark a collateral deposit as consumed for minting.
     * @param tokenId NFT tokenId linked to this collateral.
     * @param collateralTokenAddress Collateral token address.
     */
    function markMinted(uint256 tokenId, address collateralTokenAddress) external onlyOwner nonReentrant {
        if (!supportedCollateral(collateralTokenAddress)) {
            revert Vault__CollateralUnsupported(collateralTokenAddress);
        }

        s_tokenIdToCollateral[tokenId][collateralTokenAddress].minted = true;
        s_tokenIdToCollateral[tokenId][collateralTokenAddress].depositor = address(0);

        emit CollateralMinted(tokenId, collateralTokenAddress);
    }

    /**
     * @notice Refund collateral if minting was not completed.
     * @dev Enforces a 30-minute lock period to prevent frontrunning randomness.
     * @param tokenId NFT tokenId linked to this collateral.
     * @param collateralTokenAddress Collateral token address.
     */
    function refund(uint256 tokenId, address collateralTokenAddress) external onlyOwner nonReentrant {
        CollateralPosition memory currentDeposit = s_tokenIdToCollateral[tokenId][collateralTokenAddress];
        if (currentDeposit.minted) revert Vault__MintedTokensAreNotRefundable();

        uint256 depositUnlockTime = currentDeposit.timestamp + Constants.VAULT_REFUND_LOCK;
        if (block.timestamp < depositUnlockTime) {
            revert Vault__CollateralDepositLockedPeriod(depositUnlockTime);
        }
        if (!supportedCollateral(collateralTokenAddress)) {
            revert Vault__CollateralUnsupported(collateralTokenAddress);
        }

        delete s_tokenIdToCollateral[tokenId][collateralTokenAddress];

        uint256 rawDepositAmount = PrecisionScaler.normalizeToPrecision(
            currentDeposit.amount, Constants.DECIMALS, IERC20Metadata(collateralTokenAddress).decimals()
        );

        bool success = SafeERC20.trySafeTransfer(
            IERC20Metadata(collateralTokenAddress), currentDeposit.depositor, rawDepositAmount
        );
        if (!success) revert Vault__CollateralWithdrawalFailed();

        emit CollateralRefunded(tokenId, currentDeposit.depositor, collateralTokenAddress, rawDepositAmount);
    }

    /**
     * @notice Withdraw collateral to a beneficiary once mint is complete.
     * @param beneficiary Recipient of collateral.
     * @param tokenId NFT tokenId linked to this collateral.
     * @param collateralTokenAddress Collateral token address.
     */
    function withdraw(address beneficiary, uint256 tokenId, address collateralTokenAddress)
        external
        onlyOwner
        nonReentrant
    {
        if (!supportedCollateral(collateralTokenAddress)) {
            revert Vault__CollateralUnsupported(collateralTokenAddress);
        }

        CollateralPosition memory currentDeposit = s_tokenIdToCollateral[tokenId][collateralTokenAddress];
        if (currentDeposit.amount == 0) revert Vault__CollateralAmountMustBeMoreThanZero();
        if (!currentDeposit.minted) revert Vault__TokenMintPending();

        delete s_tokenIdToCollateral[tokenId][collateralTokenAddress];

        uint256 rawDepositAmount = PrecisionScaler.normalizeToPrecision(
            currentDeposit.amount, Constants.DECIMALS, IERC20Metadata(collateralTokenAddress).decimals()
        );

        bool success = SafeERC20.trySafeTransfer(IERC20Metadata(collateralTokenAddress), beneficiary, rawDepositAmount);
        if (!success) revert Vault__CollateralWithdrawalFailed();

        emit CollateralWithdrawn(tokenId, beneficiary, collateralTokenAddress, rawDepositAmount);
    }

    /**
     * @notice Get balances of all supported collaterals for a given tokenId.
     * @dev Only minted collateral is included in the response.
     * @param tokenId NFT tokenId.
     * @return collaterals Array of collateral token addresses.
     * @return amounts Array of collateral amounts in system precision.
     */
    function balanceOf(uint256 tokenId)
        external
        view
        onlyOwner
        returns (address[] memory collaterals, uint256[] memory amounts)
    {
        uint256 n = s_supportedCollaterals.length;
        collaterals = new address[](n);
        amounts = new uint256[](n);

        uint256 count = 0;
        for (uint256 i = 0; i < s_supportedCollaterals.length; i++) {
            if (s_tokenIdToCollateral[tokenId][s_supportedCollaterals[i]].minted) {
                collaterals[count] = s_supportedCollaterals[i];
                amounts[count] = s_tokenIdToCollateral[tokenId][s_supportedCollaterals[i]].amount;
                count++;
            }
        }

        // trim arrays to actual length
        assembly {
            mstore(collaterals, count)
            mstore(amounts, count)
        }
    }

    /**
     * @notice Check if a tokenId has a deposit for a given collateral token.
     * @param tokenId NFT tokenId.
     * @param collateralTokenAddress Collateral token address.
     * @return True if a deposit exists, false otherwise.
     */
    function hasDeposit(uint256 tokenId, address collateralTokenAddress) external view onlyOwner returns (bool) {
        return s_tokenIdToCollateral[tokenId][collateralTokenAddress].amount > 0;
    }

    /**
     * @notice Check if a token is supported as collateral.
     * @param token Collateral token address.
     * @return supported True if token is supported.
     */
    function supportedCollateral(address token) public view returns (bool supported) {
        for (uint256 i = 0; i < s_supportedCollaterals.length; i++) {
            if (s_supportedCollaterals[i] == token) return true;
        }
        return false;
    }
}
