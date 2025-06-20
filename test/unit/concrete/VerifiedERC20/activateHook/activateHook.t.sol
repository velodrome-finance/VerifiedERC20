// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract ActivateHookConcreteTest is VerifiedERC20Test {
    function test_WhenTheCallerIsNotTheOwner() external {
        // It should revert with {OwnableUnauthorizedAccount}

        vm.startPrank({msgSender: users.charlie});
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.charlie));
        verifiedERC20.activateHook({_hook: address(hook)});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank({msgSender: users.owner});
        _;
    }

    function test_WhenTheHookIsNotRegisteredInTheHookRegistry() external whenTheCallerIsTheOwner {
        // It should revert with {VerifiedERC20_InvalidHook}

        vm.expectRevert(abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_InvalidHook.selector, address(hook)));
        verifiedERC20.activateHook({_hook: address(hook)});
    }

    modifier whenTheHookIsRegisteredInTheHookRegistry() {
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
        _;
    }

    function test_WhenTheHookIsAlreadyActivated()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsRegisteredInTheHookRegistry
    {
        // It should revert with {VerifiedERC20_HookAlreadyActivated}
        verifiedERC20.activateHook({_hook: address(hook)});

        vm.expectRevert(
            abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_HookAlreadyActivated.selector, address(hook))
        );
        verifiedERC20.activateHook({_hook: address(hook)});
    }

    modifier whenTheHookIsNotAlreadyActivated() {
        _;
    }

    function test_WhenTheNumberOfHooksAtThatEntrypointIsMAX_NUMBER_OF_HOOKS_PER_ENTRYPOINT()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsRegisteredInTheHookRegistry
        whenTheHookIsNotAlreadyActivated
    {
        // It should revert with {VerifiedERC20_MaxHooksExceeded}

        // register in registry and activate to reach max
        for (uint256 i = 2; i < 10; i++) {
            address newHook = address(new MockSuccessHook());
            hookRegistry.registerHook({_hook: address(newHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
            verifiedERC20.activateHook({_hook: address(newHook)});
        }

        vm.expectRevert(abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_MaxHooksExceeded.selector));
        verifiedERC20.activateHook({_hook: address(hook)});
    }

    function test_WhenTheNumberOfHooksAtThatEntrypointIsNotMAX_NUMBER_OF_HOOKS_PER_ENTRYPOINT()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsRegisteredInTheHookRegistry
        whenTheHookIsNotAlreadyActivated
    {
        // It should retrieve the hook's entrypoint from the HookRegistry
        // It should add the hook to the internal `_hooksByEntrypoint` array for the correct entrypoint
        // It should update the mapping states correctly
        // It should emit a {HookActivated} event with the correct hook address and entrypoint

        vm.expectEmit({emitter: address(verifiedERC20)});
        emit IVerifiedERC20.HookActivated({hook: address(hook), entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
        verifiedERC20.activateHook({_hook: address(hook)});

        address[] memory hooksForEntrypoint = verifiedERC20.getHooksForEntrypoint(IHookRegistry.Entrypoint.BEFORE_MINT);
        assertEq(hooksForEntrypoint.length, 1);
        assertEq(hooksForEntrypoint[0], address(hook));

        address hookAtIndex = verifiedERC20.getHookAtIndex(IHookRegistry.Entrypoint.BEFORE_MINT, 0);
        assertEq(hookAtIndex, address(hook));
        assertEq(verifiedERC20.getHooksCountForEntrypoint(IHookRegistry.Entrypoint.BEFORE_MINT), 1);

        assertEq(verifiedERC20.hookToIndex(address(hook)), 0);
        assertEq(uint8(verifiedERC20.hookToEntrypoint(address(hook))), uint8(IHookRegistry.Entrypoint.BEFORE_MINT));
        assertTrue(verifiedERC20.isHookActivated(address(hook)));
    }

    function testGas_activateHook() external whenTheCallerIsTheOwner whenTheHookIsRegisteredInTheHookRegistry {
        verifiedERC20.activateHook({_hook: address(hook)});
        vm.snapshotGasLastCall({name: "VerifiedERC20_activateHook"});
    }
}
