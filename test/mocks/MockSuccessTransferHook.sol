// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {IHookRegistry} from "src/interfaces/hooks/IHookRegistry.sol";

import {BaseTransferHook} from "src/hooks/BaseTransferHook.sol";

/// @dev Mock hook that always succeeds for testing purposes.
contract MockSuccessTransferHook is BaseTransferHook {
    constructor() BaseTransferHook("MockSuccessHook") {}

    function supportsEntrypoint(IHookRegistry.Entrypoint _entrypoint) external pure override returns (bool) {
        return _entrypoint == IHookRegistry.Entrypoint.BEFORE_TRANSFER
            || _entrypoint == IHookRegistry.Entrypoint.AFTER_TRANSFER;
    }

    function _check(address, address, address, uint256) internal override {}
}
