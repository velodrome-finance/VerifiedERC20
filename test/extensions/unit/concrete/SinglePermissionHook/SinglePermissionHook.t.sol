// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseSelfForkFixture.sol";

contract SinglePermissionHookTest is BaseSelfForkFixture {
    function test_InitialState() public view {
        assertEq(singlePermissionMintHook.name(), _selfParams.singlePermissionMintHookName);
        assertEq(singlePermissionBurnHook.name(), _selfParams.singlePermissionBurnHookName);

        assertEq(singlePermissionMintHook.authorized(address(verifiedERC20)), address(lockbox));
        assertEq(singlePermissionBurnHook.authorized(address(verifiedERC20)), address(lockbox));

        assertTrue(singlePermissionMintHook.supportsEntrypoint(IHookRegistry.Entrypoint.BEFORE_MINT));
        assertTrue(singlePermissionBurnHook.supportsEntrypoint(IHookRegistry.Entrypoint.BEFORE_BURN));
    }
}
