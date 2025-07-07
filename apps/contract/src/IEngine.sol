// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

struct Meta {
    string base;
    string ring;
}

interface IEngine {
    function generateWithMeta(Meta calldata meta, uint256 tokenId) external pure returns (string memory);
}
