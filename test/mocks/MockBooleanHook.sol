// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {BaseAHook} from "src/hooks/BaseAHook.sol";

contract MockBooleanHook is BaseAHook {
    bool public hookChecked;

    constructor() BaseAHook("MockBooleanHook") {}

    function supportsInterface(bytes4) public pure override returns (bool) {
        return true;
    }

    function _check(address, address, uint256) internal override {
        if (hookChecked) revert("Hook already checked");
        hookChecked = true;
    }
}
