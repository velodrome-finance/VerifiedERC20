// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IVerifiedERC20} from "./interfaces/IVerifiedERC20.sol";

contract VerifiedERC20 is ERC20, IVerifiedERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function transfer(address to, uint256 value) public override(ERC20, IERC20) returns (bool) {
        return super.transfer({to: to, value: value});
    }

    function approve(address spender, uint256 value) public override(ERC20, IERC20) returns (bool) {
        return super.approve({spender: spender, value: value});
    }

    function transferFrom(address from, address to, uint256 value) public override(ERC20, IERC20) returns (bool) {
        return super.transferFrom({from: from, to: to, value: value});
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update({from: from, to: to, value: value});
    }
}
