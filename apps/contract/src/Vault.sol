// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

struct Deposit {
    uint256 amount;
    bool minted;
    address depositor;
}

contract Vault is Ownable, ReentrancyGuard {
    constructor() Ownable(msg.sender) {}

    mapping(uint256 tokenId => mapping(address collateralTokenAddress => Deposit deposit)) private tokenIdToDeposit;

    function deposit(uint256 tokenId, address collateralTokenAddress, uint256 amount) external payable onlyOwner {}

    function withdraw(uint256 tokenId) external onlyOwner nonReentrant {}

    function BalanceOf(uint256 tokenId) external returns (address[] memory collaterals, uint256[] memory amounts) {}
}
