// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseSelfForkFixture.sol";

contract AutoUnwrapHookTest is BaseSelfForkFixture {
    function test_InitialState() public view {
        assertEq(autoUnwrapHook.name(), _selfParams.autoUnwrapHookName);
        assertEq(autoUnwrapHook.voter(), _selfParams.voter);
        assertEq(autoUnwrapHook.lockbox(address(verifiedERC20)), address(lockbox));
        assertTrue(autoUnwrapHook.supportsEntrypoint(IHookRegistry.Entrypoint.AFTER_TRANSFER));
    }
}
