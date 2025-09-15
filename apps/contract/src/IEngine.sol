// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IEngine {
    function generateWithMeta(
        uint256 tokenId,
        string memory tokenBase,
        string memory collateralPair,
        address collateralBase,
        address collateralToken,
        address collateralPool,
        uint256 collateralAmount
    ) external view returns (string memory);

    function name() external pure returns (string memory);
    function description() external pure returns (string memory);
}
