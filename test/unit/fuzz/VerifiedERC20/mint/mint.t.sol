// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract MintFuzzTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(users.owner);
        hookRegistry.registerHook({_hook: address(beforeHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT});
        hookRegistry.registerHook({_hook: address(afterHook), _entrypoint: IHookRegistry.Entrypoint.AFTER_MINT});

        verifiedERC20.activateHook({_hook: address(beforeHook)});
        verifiedERC20.activateHook({_hook: address(afterHook)});
        vm.stopPrank();
    }

    function testFuzz_WhenTheAccountPassedIsTheZeroAddress(uint256 _amount) external {
        // It should revert with {ERC20InvalidReceiver}
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.mint({_account: address(0), _value: _amount});
    }

    function testFuzz_WhenTheAccountPassedIsNotTheZeroAddress(uint256 _amount, address _account) external {
        // It should call the before hook
        // It should call the after hook
        // It should mint the amount to the user
        vm.assume(_account != address(0));

        /// @dev check hooks are called only once per entrypoint
        vm.expectCall({
            callee: address(beforeHook),
            data: abi.encodeCall(IHook.check, (address(this), abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectCall({
            callee: address(afterHook),
            data: abi.encodeCall(IHook.check, (address(this), abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: address(0), to: _account, value: _amount});
        verifiedERC20.mint({_account: _account, _value: _amount});

        assertEq(verifiedERC20.balanceOf({account: _account}), _amount);
    }
}
