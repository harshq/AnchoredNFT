// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

interface IVault {
    function deposit(uint256 tokenId, address collateralTokenAddress, uint256 amount) external payable;
    function withdraw(uint256 tokenId) external;
    function BalanceOf(uint256 tokenId) external returns (address[] memory collaterals, uint256[] memory amounts);
}
