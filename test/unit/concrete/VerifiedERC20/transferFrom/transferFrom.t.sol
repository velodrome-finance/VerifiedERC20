// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract TransferFromConcreteTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(users.owner);
        hookRegistry.registerHook({_hook: address(beforeHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        hookRegistry.registerHook({_hook: address(afterHook), _entrypoint: IHookRegistry.Entrypoint.AFTER_TRANSFER});

        verifiedERC20.activateHook({_hook: address(beforeHook)});
        verifiedERC20.activateHook({_hook: address(afterHook)});
        vm.stopPrank();

        verifiedERC20.mint({_account: users.alice, _value: 1000});
    }

    function test_WhenTheAmountIsGreaterThanTheAllowance() external {
        // It should revert with {ERC20InsufficientAllowance}
        uint256 _amount = 1000;
        address _from = users.alice;
        address _to = users.bob;
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(this), 0, _amount)
        );
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    }

    modifier whenTheAmountIsSmallerOrEqualToTheAllowance(uint256 _amount) {
        vm.prank(users.alice);
        verifiedERC20.approve({spender: address(this), value: _amount});
        _;
    }

    function test_WhenTheFromAddressIsTheZeroAddress() external whenTheAmountIsSmallerOrEqualToTheAllowance(0) {
        // It should revert with {ERC20InvalidSender}
        uint256 _amount = 1000;
        address _to = users.bob;
        /// @dev it's not possible to approve the zero address, so the revert is InsufficientAllowance instead of InvalidSender
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(this), 0, _amount)
        );
        verifiedERC20.transferFrom({from: address(0), to: _to, value: _amount});
    }

    modifier whenTheFromAddressIsNotTheZeroAddress() {
        _;
    }

    function test_WhenTheToAddressIsTheZeroAddress()
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance(1000)
        whenTheFromAddressIsNotTheZeroAddress
    {
        // It should revert with {ERC20InvalidReceiver}
        uint256 _amount = 100;
        address _from = users.alice;
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.transferFrom({from: _from, to: address(0), value: _amount});
    }

    modifier whenTheToAddressIsNotTheZeroAddress() {
        _;
    }

    function test_WhenAmountIsGreaterThanFromBalance()
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance(1000 + 1)
        whenTheFromAddressIsNotTheZeroAddress
        whenTheToAddressIsNotTheZeroAddress
    {
        // It should revert with {ERC20InsufficientBalance}
        uint256 _amount = 1000 + 1;
        address _from = users.alice;
        address _to = users.bob;

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _from, 1000, _amount));
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    }

    function test_WhenAmountIsSmallerOrEqualToFromBalance()
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance(1000 - 1)
        whenTheFromAddressIsNotTheZeroAddress
        whenTheToAddressIsNotTheZeroAddress
    {
        // It should call the before hook
        // It should deduct the allowance
        // It should transfer the amount
        // It should call the after hook
        // It should emit a {Transfer} event
        uint256 _amount = 1000 - 1;
        address _from = users.alice;
        address _to = users.bob;
        assertEq(verifiedERC20.allowance({owner: _from, spender: address(this)}), _amount);

        assertFalse(beforeHook.hookChecked());
        assertFalse(afterHook.hookChecked());
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer(_from, _to, _amount);
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
        assertTrue(beforeHook.hookChecked());
        assertTrue(afterHook.hookChecked());
        assertEq(verifiedERC20.allowance({owner: _from, spender: address(this)}), 0);
        assertEq(verifiedERC20.balanceOf({account: _from}), 1000 - _amount);
        assertEq(verifiedERC20.balanceOf({account: _to}), _amount);
    }

    // function test_WhenTheFromAddressIsTheZeroAddress() external {
    //     // It should revert with {ERC20InvalidSender}
    //     uint256 _amount = 100;
    //     address _to = users.bob;
    //     vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidSender.selector, address(0)));
    //     verifiedERC20.transferFrom({from: address(0), to: _to, value: _amount});
    // }
    //
    // modifier whenTheFromAddressIsNotTheZeroAddress() {
    //     _;
    // }
    //
    // function test_WhenTheToAddressIsTheZeroAddress() external whenTheFromAddressIsNotTheZeroAddress {
    //     // It should revert with {ERC20InvalidReceiver}
    //     uint256 _amount = 100;
    //     address _from = users.alice;
    //     vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
    //     verifiedERC20.transferFrom({from: _from, to: address(0), value: _amount});
    // }
    //
    // modifier whenTheToAddressIsNotTheZeroAddress() {
    //     _;
    // }
    //
    // function test_WhenTheAmountIsGreaterThanTheAllowance()
    //     external
    //     whenTheFromAddressIsNotTheZeroAddress
    //     whenTheToAddressIsNotTheZeroAddress
    // {
    //     // It should revert with {ERC20InsufficientAllowance}
    //     uint256 _amount = 100;
    //     address _from = users.alice;
    //     address _to = users.bob;
    //     vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector,address(this), 0, _amount));
    //     verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    // }
    //
    // modifier whenTheAmountIsSmallerOrEqualToTheAllowance() {
    //     _;
    // }
    //
    // function test_WhenAmountIsGreaterThanFromBalance()
    //     external
    //     whenTheFromAddressIsNotTheZeroAddress
    //     whenTheToAddressIsNotTheZeroAddress
    //     whenTheAmountIsSmallerOrEqualToTheAllowance
    // {
    //     // It should revert with {ERC20InsufficientBalance}
    //     uint256 _amount = 1000 + 1;
    //     address _from = users.alice;
    //     address _to = users.bob;
    //
    //
    //     vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _from, 1000,_amount));
    //     verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    // }
    //
    // function test_WhenAmountIsSmallerOrEqualToFromBalance()
    //     external
    //     whenTheFromAddressIsNotTheZeroAddress
    //     whenTheToAddressIsNotTheZeroAddress
    //     whenTheAmountIsSmallerOrEqualToTheAllowance
    // {
    //     // It should call the before hook
    //     // It should deduct the allowance
    //     // It should transfer the amount
    //     // It should call the after hook
    //     // It should emit a {Transfer} event
    //     uint256 _amount = 1000 - 1;
    //     address _from = users.alice;
    //     address _to = users.bob;
    //     assertEq(verifiedERC20.allowance({owner: _from, spender: address(this)}), _amount);
    //
    //     assertFalse(beforeHook.hookChecked());
    //     assertFalse(afterHook.hookChecked());
    //     vm.expectEmit(address(verifiedERC20));
    //     emit IERC20.Transfer(_from, _to, _amount);
    //     verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    //     assertTrue(beforeHook.hookChecked());
    //     assertTrue(afterHook.hookChecked());
    //     assertEq(verifiedERC20.allowance({owner: _from, spender: address(this)}), 0);
    //     assertEq(verifiedERC20.balanceOf({account: _from}), 1000 - _amount);
    //     assertEq(verifiedERC20.balanceOf({account: _to}), _amount);
    // }
}
