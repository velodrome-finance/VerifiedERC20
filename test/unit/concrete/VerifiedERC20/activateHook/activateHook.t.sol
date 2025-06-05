// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract ActivateHookConcreteTest is VerifiedERC20Test {
    function test_WhenTheCallerIsNotTheOwner() external {
        // It should revert with {OwnableUnauthorizedAccount}

        vm.startPrank({msgSender: users.charlie});
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, users.charlie));
        verifiedERC20.activateHook({_hook: address(mockSuccessHook)});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank({msgSender: users.owner});
        _;
        vm.stopPrank();
    }

    function test_WhenTheHookIsNotRegisteredInTheHookRegistry() external whenTheCallerIsTheOwner {
        // It should revert with {VerifiedERC20_InvalidHook}

        vm.expectRevert(
            abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_InvalidHook.selector, address(mockSuccessHook))
        );
        verifiedERC20.activateHook({_hook: address(mockSuccessHook)});
    }

    modifier whenTheHookIsRegisteredInTheHookRegistry() {
        hookRegistry.registerHook({
            _hook: address(mockSuccessHook),
            _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER
        });
        _;
    }

    function test_WhenTheHookIsAlreadyActivated()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsRegisteredInTheHookRegistry
    {
        // It should revert with {VerifiedERC20_HookAlreadyActivated}
        verifiedERC20.activateHook({_hook: address(mockSuccessHook)});

        vm.expectRevert(
            abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_HookAlreadyActivated.selector, address(mockSuccessHook))
        );
        verifiedERC20.activateHook({_hook: address(mockSuccessHook)});
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
            hookRegistry.registerHook({_hook: address(newHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
            verifiedERC20.activateHook({_hook: address(newHook)});
        }

        vm.expectRevert(abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_MaxHooksExceeded.selector));
        verifiedERC20.activateHook({_hook: address(mockSuccessHook)});
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
        emit IVerifiedERC20.HookActivated({
            hook: address(mockSuccessHook),
            entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER
        });
        verifiedERC20.activateHook({_hook: address(mockSuccessHook)});

        address[] memory hooksForEntrypoint =
            verifiedERC20.getHooksForEntrypoint(IHookRegistry.Entrypoint.BEFORE_TRANSFER);
        assertEq(hooksForEntrypoint.length, 1);
        assertEq(hooksForEntrypoint[0], address(mockSuccessHook));

        address hookAtIndex = verifiedERC20.getHookAtIndex(IHookRegistry.Entrypoint.BEFORE_TRANSFER, 0);
        assertEq(hookAtIndex, address(mockSuccessHook));
        assertEq(verifiedERC20.getHooksCountForEntrypoint(IHookRegistry.Entrypoint.BEFORE_TRANSFER), 1);

        assertEq(verifiedERC20.hookToIndex(address(mockSuccessHook)), 0);
        assertEq(
            uint8(verifiedERC20.hookToEntrypoint(address(mockSuccessHook))),
            uint8(IHookRegistry.Entrypoint.BEFORE_TRANSFER)
        );
        assertTrue(verifiedERC20.isHookActivated(address(mockSuccessHook)));
    }

    function testGas_activateHook() external whenTheCallerIsTheOwner whenTheHookIsRegisteredInTheHookRegistry {
        verifiedERC20.activateHook({_hook: address(mockSuccessHook)});
        vm.snapshotGasLastCall({name: "VerifiedERC20_activateHook"});
    }
}
