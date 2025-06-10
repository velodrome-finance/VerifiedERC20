// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import '../VerifiedERC20.t.sol';

contract BurnConcreteTest is VerifiedERC20Test {
  function setUp() public override {
    super.setUp();

    vm.startPrank(users.owner);
    hookRegistry.registerHook({
      _hook: address(beforeHook),
      _entrypoint: IHookRegistry.Entrypoint.BEFORE_BURN
    });
    hookRegistry.registerHook({
      _hook: address(afterHook),
      _entrypoint: IHookRegistry.Entrypoint.AFTER_BURN
    });

    verifiedERC20.activateHook({ _hook: address(beforeHook) });
    verifiedERC20.activateHook({ _hook: address(afterHook) });
    vm.stopPrank();

    verifiedERC20.mint({ _account: users.alice, _value: 1000 });
  }

  function test_WhenTheAccountPassedIsTheZeroAddress() external {
    // It should revert with {ERC20InvalidSender}
    uint256 _amount = 100;
    vm.expectRevert(
      abi.encodeWithSelector(
        IERC20Errors.ERC20InvalidSender.selector,
        address(0)
      )
    );
    verifiedERC20.burn({ _account: address(0), _value: _amount });
  }

  modifier whenTheAccountPassedIsNotTheZeroAddress() {
    _;
  }

  function test_WhenTheAmountIsGreaterThanTheUsersBalance()
    external
    whenTheAccountPassedIsNotTheZeroAddress
  {
    // It should revert with {ERC20InsufficientBalance}
    uint256 _amount = 1000 + 1;

    vm.expectRevert(
      abi.encodeWithSelector(
        IERC20Errors.ERC20InsufficientBalance.selector,
        address(users.alice),
        1000,
        _amount
      )
    );
    verifiedERC20.burn({ _account: users.alice, _value: _amount });
  }

  function test_WhenTheAmountIsSmallerOrEqualToTheUsersBalance()
    external
    whenTheAccountPassedIsNotTheZeroAddress
  {
    // It should call the before hook
    // It should call the after hook
    // It should burn the amount from the user
    uint256 _amount = 1000 - 1;
    address _account = users.alice;

    /// @dev check hooks are called only once per entrypoint
    vm.expectCall({
      callee: address(beforeHook),
      data: abi.encodeCall(
        IHook.check,
        (address(this), abi.encode(_account, _amount))
      ),
      count: 1
    });
    vm.expectCall({
      callee: address(afterHook),
      data: abi.encodeCall(
        IHook.check,
        (address(this), abi.encode(_account, _amount))
      ),
      count: 1
    });
    vm.expectEmit(address(verifiedERC20));
    emit IERC20.Transfer({ from: _account, to: address(0), value: _amount });
    verifiedERC20.burn({ _account: _account, _value: _amount });

    assertEq(verifiedERC20.balanceOf({ account: _account }), 1000 - _amount);
  }
}
