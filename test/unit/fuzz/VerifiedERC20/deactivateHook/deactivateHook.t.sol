// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract DeactivateHookFuzzTest is VerifiedERC20Test {
    function testFuzz_WhenTheCallerIsNotTheOwner(address _caller) external {
        // It should revert with {OwnableUnauthorizedAccount}
        vm.assume(_caller != users.owner);
        vm.startPrank({msgSender: _caller});
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _caller));
        verifiedERC20.deactivateHook({_hook: address(hook)});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank({msgSender: users.owner});
        _;
    }

    function testFuzz_WhenTheHookIsNotActivated(address _hook) external whenTheCallerIsTheOwner {
        // It should revert with {VerifiedERC20_HookNotActivated}
        vm.expectRevert(abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_HookNotActivated.selector, _hook));
        verifiedERC20.deactivateHook({_hook: _hook});
    }

    modifier whenTheHookIsActivated() {
        _;
    }

    function testFuzz_WhenTheHookIsTheOnlyElementInTheArray() external whenTheCallerIsTheOwner whenTheHookIsActivated {}

    function testFuzz_WhenTheHookIsTheLastElementInTheArrayButNotTheOnlyElement()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsActivated
    {}

    function testFuzz_WhenTheHookIsNotTheLastElementInTheArray()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsActivated
    {}
}
