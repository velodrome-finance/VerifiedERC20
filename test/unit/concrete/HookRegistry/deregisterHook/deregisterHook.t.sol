// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../HookRegistry.t.sol";

contract DeregisterHookConcreteTest is HookRegistryTest {
    function test_WhenTheCallerIsNotTheOwner() external {
        // It should revert with {OwnableUnauthorizedAccount}
        vm.prank(users.charlie);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.charlie));
        hookRegistry.deregisterHook({_hook: address(hook)});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank(users.owner);
        _;
    }

    function test_WhenTheHookIsNotRegistered() external whenTheCallerIsTheOwner {
        // It should revert with {HookRegistry_HookNotRegistered}
        vm.expectRevert(IHookRegistry.HookRegistry_HookNotRegistered.selector);
        hookRegistry.deregisterHook({_hook: address(hook)});
    }

    modifier whenTheHookIsRegistered() {
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
        _;
    }

    function test_WhenTheHookIsRegistered() external whenTheCallerIsTheOwner whenTheHookIsRegistered {
        // It should remove the hook from the hook enumerable set
        // It should clear the hook entrypoint mapping
        // It should emit a {HookDeregistered} event

        vm.expectEmit(address(hookRegistry));
        emit IHookRegistry.HookDeregistered({hook: address(hook)});
        hookRegistry.deregisterHook({_hook: address(hook)});

        // Verify hook is properly deregistered
        assertEq(hookRegistry.getHookCount(), 0);
        assertFalse(hookRegistry.isHookRegistered({_hook: address(hook)}));
        assertEq(uint256(hookRegistry.hookEntrypoints({_hook: address(hook)})), 0);
    }

    function testGas_deregisterHook() external whenTheCallerIsTheOwner whenTheHookIsRegistered {
        hookRegistry.deregisterHook({_hook: address(hook)});
        vm.snapshotGasLastCall({name: "HookRegistry_deregisterHook"});
    }
}
