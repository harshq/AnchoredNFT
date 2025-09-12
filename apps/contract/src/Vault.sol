// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {PrecisionScaler} from "src/PrecisionScaler.sol";
import {Constants} from "src/Constants.sol";

struct CollateralPosition {
    uint256 amount;
    bool minted;
    address depositor;
    uint256 timestamp;
}

contract Vault is Ownable, ReentrancyGuard {
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

    address[] private s_supportedCollaterals;
    mapping(uint256 tokenId => mapping(address collateralTokenAddress => CollateralPosition collateral)) private
        s_tokenIdToCollateral;

    constructor(address[] memory supportedCollaterals) Ownable(msg.sender) {
        s_supportedCollaterals = supportedCollaterals;
    }

    function deposit(address depositor, uint256 tokenId, address collateralTokenAddress, uint256 rawDepositAmount)
        external
        payable
        onlyOwner
        nonReentrant
    {
        // Checks
        if (rawDepositAmount == 0) {
            revert Vault__CollateralAmountMustBeMoreThanZero();
        }

        if (!supportedCollateral(collateralTokenAddress)) {
            revert Vault__CollateralUnsupported(collateralTokenAddress);
        }

        // Effects
        CollateralPosition storage pos = s_tokenIdToCollateral[tokenId][collateralTokenAddress];
        pos.amount += PrecisionScaler.normalizeToSystemPrecision(
            rawDepositAmount, IERC20Metadata(collateralTokenAddress).decimals()
        );
        pos.depositor = depositor;
        pos.minted = false;
        pos.timestamp = block.timestamp;

        // Intractions
        bool success = SafeERC20.trySafeTransferFrom(
            IERC20Metadata(collateralTokenAddress), depositor, address(this), rawDepositAmount
        );
        if (!success) {
            revert Vault__CollateralDepositFailed();
        }

        emit DepositMade(depositor, collateralTokenAddress, tokenId, rawDepositAmount);
    }

    function markMinted(uint256 tokenId, address collateralTokenAddress) external onlyOwner nonReentrant {
        // Checks
        if (!supportedCollateral(collateralTokenAddress)) {
            revert Vault__CollateralUnsupported(collateralTokenAddress);
        }

        // Effects
        s_tokenIdToCollateral[tokenId][collateralTokenAddress].minted = true;
        s_tokenIdToCollateral[tokenId][collateralTokenAddress].depositor = address(0);

        emit CollateralMinted(tokenId, collateralTokenAddress);
    }

    function refund(uint256 tokenId, address collateralTokenAddress) external onlyOwner nonReentrant {
        // Checks
        CollateralPosition memory currentDeposit = s_tokenIdToCollateral[tokenId][collateralTokenAddress];
        if (currentDeposit.minted) {
            revert Vault__MintedTokensAreNotRefundable();
        }

        // funds are locked for 30mins. This is to prevent
        // removing funds while randomness is happening.
        uint256 depositUnlockTime = currentDeposit.timestamp + 30 minutes;
        if (block.timestamp < depositUnlockTime) {
            revert Vault__CollateralDepositLockedPeriod(depositUnlockTime);
        }

        if (!supportedCollateral(collateralTokenAddress)) {
            revert Vault__CollateralUnsupported(collateralTokenAddress);
        }

        // Effects
        delete s_tokenIdToCollateral[tokenId][collateralTokenAddress];

        uint256 rawDepositAmount = PrecisionScaler.normalizeToPrecision(
            currentDeposit.amount, Constants.DECIMALS, IERC20Metadata(collateralTokenAddress).decimals()
        );

        // Intractions
        bool success = SafeERC20.trySafeTransfer(
            IERC20Metadata(collateralTokenAddress), currentDeposit.depositor, rawDepositAmount
        );

        if (!success) {
            revert Vault__CollateralWithdrawalFailed();
        }

        emit CollateralRefunded(tokenId, currentDeposit.depositor, collateralTokenAddress, rawDepositAmount);
    }

    function withdraw(address beneficiary, uint256 tokenId, address collateralTokenAddress)
        external
        onlyOwner
        nonReentrant
    {
        // Checks
        if (!supportedCollateral(collateralTokenAddress)) {
            revert Vault__CollateralUnsupported(collateralTokenAddress);
        }

        CollateralPosition memory currentDeposit = s_tokenIdToCollateral[tokenId][collateralTokenAddress];
        if (currentDeposit.amount == 0) {
            revert Vault__CollateralAmountMustBeMoreThanZero();
        }

        // not marked minted
        if (!currentDeposit.minted) {
            revert Vault__TokenMintPending();
        }

        // Effects
        delete s_tokenIdToCollateral[tokenId][collateralTokenAddress];

        // Intractions
        uint256 rawDepositAmount = PrecisionScaler.normalizeToPrecision(
            currentDeposit.amount, Constants.DECIMALS, IERC20Metadata(collateralTokenAddress).decimals()
        );

        bool success = SafeERC20.trySafeTransfer(IERC20Metadata(collateralTokenAddress), beneficiary, rawDepositAmount);
        if (!success) {
            revert Vault__CollateralWithdrawalFailed();
        }

        emit CollateralWithdrawn(tokenId, beneficiary, collateralTokenAddress, rawDepositAmount);
    }

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

    function hasDeposit(uint256 tokenId, address collateralTokenAddress) external view onlyOwner returns (bool) {
        return s_tokenIdToCollateral[tokenId][collateralTokenAddress].amount > 0;
    }

    function supportedCollateral(address token) public view returns (bool supported) {
        for (uint256 i = 0; i < s_supportedCollaterals.length; i++) {
            if (s_supportedCollaterals[i] == token) {
                return true;
            }
        }

        return false;
    }
}
