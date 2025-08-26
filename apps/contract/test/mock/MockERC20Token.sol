// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

// import {Test} from "forge-std/Test.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20Token is ERC20 {
    uint8 private immutable i_decimals;

    constructor(string memory name_, string memory symbol_, uint8 _decimals) ERC20(name_, symbol_) {
        i_decimals = _decimals;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function decimals() public view override returns (uint8) {
        return i_decimals;
    }
}
