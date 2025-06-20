// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract TransferFuzzTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(users.owner);
        hookRegistry.registerHook({_hook: address(beforeHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        hookRegistry.registerHook({_hook: address(afterHook), _entrypoint: IHookRegistry.Entrypoint.AFTER_TRANSFER});

        verifiedERC20.activateHook({_hook: address(beforeHook)});
        verifiedERC20.activateHook({_hook: address(afterHook)});
        vm.stopPrank();

        vm.startPrank(users.alice);
    }

    function _deployHooks() internal override {
        beforeHook = new MockSuccessTransferHook();
        afterHook = new MockSuccessTransferHook();

        vm.label(address(beforeHook), "beforeHook");
        vm.label(address(afterHook), "afterHook");
    }

    function testFuzz_WhenTheToAddressPassedIsTheZeroAddress(uint256 _amount) external {
        // It should revert with {ERC20InvalidReceiver}
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.transfer({to: address(0), value: _amount});
    }

    modifier whenTheToAddressPassedIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenAmountIsGreaterThanBalance(uint256 _amount, uint256 _balance, address _to)
        external
        whenTheToAddressPassedIsNotTheZeroAddress
    {
        // It should revert with {ERC20InsufficientBalance}
        vm.assume(_to != address(0));
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, 0, _amount - 1);
        verifiedERC20.mint({_account: users.alice, _value: _balance});
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, users.alice, _balance, _amount)
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    function testFuzz_WhenAmountIsSmallerOrEqualToBalance(uint256 _amount, uint256 _balance, address _to)
        external
        whenTheToAddressPassedIsNotTheZeroAddress
    {
        // It should call the before hook
        // It should call the after hook
        // It should emit a {Transfer} event
        // It should transfer the amount
        vm.assume(_to != address(0));
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, _amount, MAX_TOKENS);
        address _from = users.alice;
        verifiedERC20.mint({_account: _from, _value: _balance});
        /// @dev check hooks are called only once per entrypoint
        vm.expectCall({
            callee: address(beforeHook),
            data: abi.encodeCall(IHook.check, (_from, abi.encode(_from, _to, _amount))),
            count: 1
        });
        vm.expectCall({
            callee: address(afterHook),
            data: abi.encodeCall(IHook.check, (_from, abi.encode(_from, _to, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _from, to: _to, value: _amount});
        verifiedERC20.transfer({to: _to, value: _amount});
        assertEq(verifiedERC20.balanceOf(_from), _balance - _amount);
        assertEq(verifiedERC20.balanceOf(_to), _amount);
    }
}
