// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract ActivateHookFuzzTest is VerifiedERC20Test {
    function testFuzz_WhenTheCallerIsNotTheOwner(address _caller) external {
        // It should revert with {OwnableUnauthorizedAccount}

        vm.assume(_caller != users.owner);
        vm.startPrank({msgSender: _caller});
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _caller));
        verifiedERC20.activateHook({_hook: address(hook)});
    }

    modifier whenTheCallerIsTheOwner() {
        vm.startPrank({msgSender: users.owner});
        _;
    }

    function testFuzz_WhenTheHookIsNotRegisteredInTheHookRegistry(address _hook) external whenTheCallerIsTheOwner {
        // It should revert with {VerifiedERC20_InvalidHook}

        vm.expectRevert(abi.encodeWithSelector(IVerifiedERC20.VerifiedERC20_InvalidHook.selector, _hook));
        verifiedERC20.activateHook({_hook: _hook});
    }

    modifier whenTheHookIsRegisteredInTheHookRegistry() {
        hookRegistry.registerHook({_hook: address(hook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
        _;
    }

    function testFuzz_WhenTheHookIsAlreadyActivated()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsRegisteredInTheHookRegistry
    {}

    modifier whenTheHookIsNotAlreadyActivated() {
        _;
    }

    function testFuzz_WhenTheNumberOfHooksAtThatEntrypointIsMAX_NUMBER_OF_HOOKS_PER_ENTRYPOINT()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsRegisteredInTheHookRegistry
        whenTheHookIsNotAlreadyActivated
    {}

    function testFuzz_WhenTheNumberOfHooksAtThatEntrypointIsNotMAX_NUMBER_OF_HOOKS_PER_ENTRYPOINT()
        external
        whenTheCallerIsTheOwner
        whenTheHookIsRegisteredInTheHookRegistry
        whenTheHookIsNotAlreadyActivated
    {}
}
