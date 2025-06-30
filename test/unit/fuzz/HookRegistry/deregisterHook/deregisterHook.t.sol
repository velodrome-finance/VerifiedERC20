// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../HookRegistry.t.sol";

contract DeregisterHookFuzzTest is HookRegistryTest {
    function testFuzz_WhenTheCallerIsNotTheOwner(address _caller) external {
        // It should revert with {OwnableUnauthorizedAccount}
        vm.assume(_caller != users.owner);
        vm.prank(_caller);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _caller));
        hookRegistry.deregisterHook({_hook: address(hook)});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank(users.owner);
        _;
    }

    function testFuzz_WhenTheHookIsNotRegistered() external whenTheCallerIsTheOwner {}

    modifier whenTheHookIsRegistered() {
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
        _;
    }

    function test_WhenTheHookIsRegistered() external whenTheCallerIsTheOwner whenTheHookIsRegistered {}
}
