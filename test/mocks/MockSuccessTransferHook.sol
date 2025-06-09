// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "src/hooks/BaseTransferHook.sol";

/// @dev Mock hook that always succeeds for testing purposes.
contract MockSuccessTransferHook is BaseTransferHook {
    constructor() BaseTransferHook("MockSuccessHook") {}

    function supportsEntrypoint(IHookRegistry.Entrypoint _entrypoint) external pure override returns (bool) {
        return _entrypoint == IHookRegistry.Entrypoint.BEFORE_TRANSFER
            || _entrypoint == IHookRegistry.Entrypoint.AFTER_TRANSFER;
    }

    function _check(address, address, address, uint256) internal override {}
}
