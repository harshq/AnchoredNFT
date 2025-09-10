// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IVault {
    function deposit(address depositor, uint256 tokenId, address collateralTokenAddress, uint256 amount)
        external
        payable;

    function markMinted(uint256 tokenId, address collateralTokenAddress) external;

    function withdraw(address beneficiary, uint256 tokenId, address collateralTokenAddress) external;

    function refund(uint256 tokenId, address collateralTokenAddress) external;

    function balanceOf(uint256 tokenId)
        external
        view
        returns (address[] memory collaterals, uint256[] memory amounts);
}
