// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import { IHookRegistry } from 'src/interfaces/hooks/IHookRegistry.sol';

import { BaseHook } from 'src/hooks/BaseHook.sol';

/// @dev Mock hook that always succeeds for testing purposes.
contract MockSuccessHook is BaseHook {
  constructor() BaseHook('MockSuccessHook') {}

  function supportsEntrypoint(
    IHookRegistry.Entrypoint _entrypoint
  ) external pure override returns (bool) {
    return
      _entrypoint == IHookRegistry.Entrypoint.BEFORE_MINT ||
      _entrypoint == IHookRegistry.Entrypoint.AFTER_MINT ||
      _entrypoint == IHookRegistry.Entrypoint.BEFORE_BURN ||
      _entrypoint == IHookRegistry.Entrypoint.AFTER_BURN ||
      _entrypoint == IHookRegistry.Entrypoint.BEFORE_APPROVE ||
      _entrypoint == IHookRegistry.Entrypoint.AFTER_APPROVE;
  }

  function _check(address, address, uint256) internal override {}
}
