// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../HookRegistry.t.sol";

contract RegisterHookFuzzTest is HookRegistryTest {
    function testFuzz_WhenTheCallerIsNotTheOwner(address _caller) external {
        // It should revert with {OwnableUnauthorizedAccount}
        vm.assume(_caller != users.owner);
        vm.prank(_caller);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _caller));
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank(users.owner);
        _;
    }

    function test_WhenTheHookIsTheZeroAddress() external whenTheCallerIsTheOwner {}

    modifier whenTheHookIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenTheHookIsAlreadyRegistered()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsNotTheZeroAddress
    {}

    modifier whenTheHookIsNotAlreadyRegistered() {
        _;
    }

    function testFuzz_WhenTheHookDoesNotSupportTheEntrypoint(uint256 _entrypoint)
        external
        whenTheCallerIsTheOwner
        whenTheHookIsNotTheZeroAddress
        whenTheHookIsNotAlreadyRegistered
    {
        _entrypoint = bound(_entrypoint, 0, 7);
        IHookRegistry.Entrypoint entrypoint = IHookRegistry.Entrypoint(_entrypoint);
        vm.assume(!hook.supportsEntrypoint(entrypoint));
        // It should revert with {HookRegistry_HookDoesNotSupportEntrypoint}
        vm.expectRevert(
            abi.encodeWithSelector(IHookRegistry.HookRegistry_HookDoesNotSupportEntrypoint.selector, entrypoint)
        );
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: entrypoint});
    }

    function testFuzz_WhenTheHookSupportsTheEntrypoint()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsNotTheZeroAddress
        whenTheHookIsNotAlreadyRegistered
    {}
}
