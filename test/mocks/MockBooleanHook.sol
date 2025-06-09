// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {BaseHook} from "src/hooks/BaseHook.sol";

contract MockBooleanHook is BaseHook {
    bool public hookChecked;

    constructor() BaseHook("MockBooleanHook") {}

    function supportsInterface(bytes4) public pure override returns (bool) {
        return true;
    }

    function _check(address, address, uint256) internal override {
        if (hookChecked) revert("Hook already checked");
        hookChecked = true;
    }
}
