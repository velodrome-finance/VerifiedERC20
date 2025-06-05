// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {BaseAHook} from "src/hooks/BaseAHook.sol";

contract MockSuccessHook is BaseAHook {
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return true;
    }

    function _check(address _caller, address _address, uint256 _amount) internal override {}
}
