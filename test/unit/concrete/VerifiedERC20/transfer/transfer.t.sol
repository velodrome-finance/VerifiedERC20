// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract TransferConcreteTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(users.owner);
        hookRegistry.registerHook({_hook: address(beforeHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        hookRegistry.registerHook({_hook: address(afterHook), _entrypoint: IHookRegistry.Entrypoint.AFTER_TRANSFER});

        verifiedERC20.activateHook({_hook: address(beforeHook)});
        verifiedERC20.activateHook({_hook: address(afterHook)});
        vm.stopPrank();

        verifiedERC20.mint({_account: users.alice, _value: 1000});
        vm.startPrank(users.alice);
    }

    function test_WhenTheToAddressPassedIsTheZeroAddress() external {
        // It should revert with {ERC20InvalidReceiver}
        uint256 _amount = 100;
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.transfer({to: address(0), value: _amount});
    }

    modifier whenTheToAddressPassedIsNotTheZeroAddress() {
        _;
    }

    function test_WhenAmountIsGreaterThanBalance() external whenTheToAddressPassedIsNotTheZeroAddress {
        // It should revert with {ERC20InsufficientBalance}
        uint256 _amount = 1000 + 1;
        address _to = users.bob;
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, users.alice, 1000, _amount)
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    function test_WhenAmountIsSmallerOrEqualToBalance() external whenTheToAddressPassedIsNotTheZeroAddress {
        // It should call the before hook
        // It should call the after hook
        // It should emit a {Transfer} event
        // It should transfer the amount
        uint256 _amount = 1000 - 1;
        address _to = users.bob;
        assertFalse(beforeHook.hookChecked());
        assertFalse(afterHook.hookChecked());
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: users.alice, to: _to, value: _amount});
        verifiedERC20.transfer({to: _to, value: _amount});
        assertTrue(beforeHook.hookChecked());
        assertTrue(afterHook.hookChecked());
        assertEq(verifiedERC20.balanceOf(users.alice), 1000 - _amount);
        assertEq(verifiedERC20.balanceOf(_to), _amount);
    }
}
