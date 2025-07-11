// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../HookRegistry.t.sol";

contract RegisterHookConcreteTest is HookRegistryTest {
    function test_WhenTheCallerIsNotTheOwner() external {
        // It should revert with {OwnableUnauthorizedAccount}
        vm.prank(users.charlie);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.charlie));
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank(users.owner);
        _;
    }

    function test_WhenTheHookIsTheZeroAddress() external whenTheCallerIsTheOwner {
        // It should revert with {HookRegistry_ZeroAddress}
        vm.expectRevert(IHookRegistry.HookRegistry_ZeroAddress.selector);
        hookRegistry.registerHook({_hook: address(0), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
    }

    modifier whenTheHookIsNotTheZeroAddress() {
        _;
    }

    function test_WhenTheHookIsAlreadyRegistered() external whenTheCallerIsTheOwner whenTheHookIsNotTheZeroAddress {
        // It should revert with {HookRegistry_HookAlreadyRegistered}
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});

        vm.expectRevert(IHookRegistry.HookRegistry_HookAlreadyRegistered.selector);
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
    }

    modifier whenTheHookIsNotAlreadyRegistered() {
        _;
    }

    function test_WhenTheHookDoesNotSupportTheEntrypoint()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsNotTheZeroAddress
        whenTheHookIsNotAlreadyRegistered
    {
        // It should revert with {HookRegistry_HookDoesNotSupportEntrypoint}
        vm.expectRevert(
            abi.encodeWithSelector(
                IHookRegistry.HookRegistry_HookDoesNotSupportEntrypoint.selector,
                IHookRegistry.Entrypoint.AFTER_TRANSFER
            )
        );
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.AFTER_TRANSFER});
    }

    function test_WhenTheHookSupportsTheEntrypoint()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsNotTheZeroAddress
        whenTheHookIsNotAlreadyRegistered
    {
        // It should add the hook to the hook enumerable set
        // It should set the hook entrypoint
        // It should emit a {HookRegistered} event
        IHookRegistry.Entrypoint entrypoint = IHookRegistry.Entrypoint.BEFORE_MINT;

        vm.expectEmit(address(hookRegistry));
        emit IHookRegistry.HookRegistered({hook: address(hook), entrypoint: entrypoint});
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: entrypoint});

        // Verify hook is properly registered
        assertEq(hookRegistry.getHookCount(), 1);
        assertEq(hookRegistry.getHookAt({_index: 0}), address(hook));
        assertTrue(hookRegistry.isHookRegistered({_hook: address(hook)}));
        assertEq(uint256(hookRegistry.hookEntrypoints({_hook: address(hook)})), uint256(entrypoint));
    }

    function testGas_registerHook() external whenTheCallerIsTheOwner whenTheHookIsNotTheZeroAddress {
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
        vm.snapshotGasLastCall({name: "HookRegistry_registerHook"});
    }
}
