// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract DeactivateHookConcreteTest is VerifiedERC20Test {
    function test_WhenTheCallerIsNotTheOwner() external {
        // It should revert with {OwnableUnauthorizedAccount}
        vm.startPrank({msgSender: users.charlie});
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.charlie));
        verifiedERC20.deactivateHook({_hook: address(hook)});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank({msgSender: users.owner});
        _;
        vm.stopPrank();
    }

    function test_WhenTheHookIsNotActivated() external whenTheCallerIsTheOwner {
        // It should revert with {VerifiedERC20_HookNotActivated}
        vm.expectRevert(abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_HookNotActivated.selector, address(hook)));
        verifiedERC20.deactivateHook({_hook: address(hook)});
    }

    modifier whenTheHookIsActivated() {
        _;
    }

    function test_WhenTheHookIsTheOnlyElementInTheArray() external whenTheCallerIsTheOwner whenTheHookIsActivated {
        // It should remove the hook from the hooks array
        // It should delete the hook from hookToIndex mapping
        // It should delete the hook from hookToEntrypoint mapping
        // It should set isHookActivated to false
        // It should emit a {HookDeactivated} event
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        verifiedERC20.activateHook({_hook: address(hook)});

        vm.expectEmit({emitter: address(verifiedERC20)});
        emit IVerifiedERC20.HookDeactivated({hook: address(hook), entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        verifiedERC20.deactivateHook({_hook: address(hook)});

        assertEq(verifiedERC20.getHooksCountForEntrypoint({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER}), 0);
        assertFalse(verifiedERC20.isHookActivated({_hook: address(hook)}));
        assertEq(verifiedERC20.hookToIndex({_hook: address(hook)}), 0);
        assertEq(uint8(verifiedERC20.hookToEntrypoint({_hook: address(hook)})), 0);
    }

    function test_WhenTheHookIsTheLastElementInTheArrayButNotTheOnlyElement()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsActivated
    {
        // It should remove the hook from the hooks array
        // It should delete the hook from hookToIndex mapping
        // It should delete the hook from hookToEntrypoint mapping
        // It should set isHookActivated to false
        // It should emit a {HookDeactivated} event

        address firstHook = makeAddr("firstHook");
        address secondHook = address(hook);

        hookRegistry.registerHook({_hook: firstHook, _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        hookRegistry.registerHook({_hook: secondHook, _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});

        verifiedERC20.activateHook({_hook: firstHook});
        verifiedERC20.activateHook({_hook: secondHook});

        assertEq(verifiedERC20.getHooksCountForEntrypoint({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER}), 2);
        assertEq(verifiedERC20.hookToIndex({_hook: secondHook}), 1);

        vm.expectEmit({emitter: address(verifiedERC20)});
        emit IVerifiedERC20.HookDeactivated({hook: secondHook, entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        verifiedERC20.deactivateHook({_hook: secondHook});

        assertEq(verifiedERC20.getHooksCountForEntrypoint({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER}), 1);
        assertFalse(verifiedERC20.isHookActivated({_hook: secondHook}));
        assertEq(verifiedERC20.hookToIndex({_hook: secondHook}), 0);
        assertEq(uint8(verifiedERC20.hookToEntrypoint({_hook: secondHook})), 0);

        assertTrue(verifiedERC20.isHookActivated({_hook: firstHook}));
        assertEq(verifiedERC20.hookToIndex({_hook: firstHook}), 0);
        assertEq(
            verifiedERC20.getHookAtIndex({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER, _index: 0}), firstHook
        );
    }

    function test_WhenTheHookIsNotTheLastElementInTheArray() external whenTheCallerIsTheOwner whenTheHookIsActivated {
        // It should swap the hook with the last element
        // It should update the swapped hook's index in hookToIndex mapping
        // It should remove the last element from the hooks array
        // It should delete the hook from hookToIndex mapping
        // It should delete the hook from hookToEntrypoint mapping
        // It should set isHookActivated to false
        // It should emit a {HookDeactivated} event

        address firstHook = makeAddr("firstHook");
        address secondHook = address(hook);
        address thirdHook = makeAddr("thirdHook");

        hookRegistry.registerHook({_hook: firstHook, _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        hookRegistry.registerHook({_hook: secondHook, _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        hookRegistry.registerHook({_hook: thirdHook, _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});

        verifiedERC20.activateHook({_hook: firstHook});
        verifiedERC20.activateHook({_hook: secondHook});
        verifiedERC20.activateHook({_hook: thirdHook});

        assertEq(verifiedERC20.getHooksCountForEntrypoint({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER}), 3);
        assertEq(verifiedERC20.hookToIndex({_hook: firstHook}), 0);
        assertEq(verifiedERC20.hookToIndex({_hook: secondHook}), 1);
        assertEq(verifiedERC20.hookToIndex({_hook: thirdHook}), 2);

        vm.expectEmit({emitter: address(verifiedERC20)});
        emit IVerifiedERC20.HookDeactivated({hook: secondHook, entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        verifiedERC20.deactivateHook({_hook: secondHook});

        assertTrue(verifiedERC20.isHookActivated({_hook: firstHook}));
        assertEq(verifiedERC20.hookToIndex({_hook: firstHook}), 0);
        assertEq(
            verifiedERC20.getHookAtIndex({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER, _index: 0}), firstHook
        );

        assertEq(verifiedERC20.getHooksCountForEntrypoint({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER}), 2);
        assertFalse(verifiedERC20.isHookActivated({_hook: secondHook}));
        assertEq(verifiedERC20.hookToIndex({_hook: secondHook}), 0);
        assertEq(uint8(verifiedERC20.hookToEntrypoint({_hook: secondHook})), 0);

        assertTrue(verifiedERC20.isHookActivated({_hook: thirdHook}));
        assertEq(verifiedERC20.hookToIndex({_hook: thirdHook}), 1);
        assertEq(
            verifiedERC20.getHookAtIndex({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER, _index: 1}), thirdHook
        );
    }

    function testGas_deactivateHook() external whenTheCallerIsTheOwner whenTheHookIsActivated {
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        verifiedERC20.activateHook({_hook: address(hook)});

        verifiedERC20.deactivateHook({_hook: address(hook)});
        vm.snapshotGasLastCall({name: "VerifiedERC20_deactivateHook"});
    }
}
