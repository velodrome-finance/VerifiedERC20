// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseSelfForkFixture.sol";

contract SelfTransferHookTest is BaseSelfForkFixture {
    function test_InitialState() public view {
        assertEq(selfTransferHook.name(), _selfParams.selfTransferHookName);
        assertEq(selfTransferHook.voter(), _selfParams.voter);
        assertEq(selfTransferHook.selfPassportSBT(), _selfParams.selfPassportSBT);
        assertTrue(selfTransferHook.supportsEntrypoint(IHookRegistry.Entrypoint.BEFORE_TRANSFER));
    }
}
