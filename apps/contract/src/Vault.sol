// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

enum CollateralType {
    wBTC,
    wETH
}

contract Vault is Ownable {
    mapping(uint256 tokenId => mapping(CollateralType collateralType => uint256 amount)) private tokenIdToDeposit;

    constructor() Ownable(msg.sender) {}

    function deposit(uint256 tokenId, CollateralType depositType, uint256 amount) external payable {}

    function withdraw(uint256 tokenId) external {}
}
