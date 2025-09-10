// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

library FixedPointString {
    using Strings for uint256;

    function toFixedStringSigned(int256 value, uint8 decimals, uint8 precision) internal pure returns (string memory) {
        bool negative = value < 0;
        uint256 abs = negative ? uint256(-value) : uint256(value);

        uint256 intPart = abs / (10 ** decimals);
        uint256 frac = abs % (10 ** decimals);
        uint256 scaled = frac / (10 ** (decimals - precision));

        string memory a = Strings.toString(intPart);
        string memory b = Strings.toString(scaled);

        // left-pad fractional part
        if (bytes(b).length < precision) {
            b = string(abi.encodePacked(string(new bytes(precision - bytes(b).length)), b));
        }

        string memory core = string(abi.encodePacked(a, ".", b));
        return negative ? string(abi.encodePacked("-", core)) : core;
    }
}
