// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseForkFixture.sol";

contract HookRegistryTest is BaseForkFixture {
    address hook = address(1);

    function test_InitialState() public view {
        assertEq(hookRegistry.getHookCount(), 0);

        address[] memory allHooks = hookRegistry.getAllHooks();
        assertEq(allHooks.length, 0);
    }
}
