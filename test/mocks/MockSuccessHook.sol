// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {BaseHook} from "src/hooks/BaseHook.sol";

contract MockSuccessHook is BaseHook {
    constructor() BaseHook("MockSuccessHook") {}

    function supportsInterface(bytes4) public pure override returns (bool) {
        return true;
    }

    function _check(address, address, uint256) internal override {}
}
