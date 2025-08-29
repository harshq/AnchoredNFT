// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {MockERC20Token} from "test/mock/MockERC20Token.sol";

contract WETHMock is MockERC20Token {
    constructor() MockERC20Token("wETH", "wETH", 18) {}
}
