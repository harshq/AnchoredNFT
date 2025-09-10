// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {MockERC20Token} from "test/mock/MockERC20Token.sol";

contract WBTCMock is MockERC20Token {
    constructor() MockERC20Token("wBTC", "wBTC", 8) {}
}
