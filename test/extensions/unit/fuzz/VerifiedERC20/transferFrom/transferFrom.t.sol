// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract TransferFromFuzzTest is VerifiedERC20Test {
    function testFuzz_WhenTheAmountIsGreaterThanTheAllowance(
        uint256 _amount,
        uint256 _allowance,
        address _from,
        address _to,
        address _caller
    ) external {
        // It should revert with {ERC20InsufficientAllowance}
        vm.assume(_caller != address(0) && _from != address(0));
        _amount = bound(_amount, 1, MAX_TOKENS);
        _allowance = bound(_allowance, 0, _amount - 1);
        vm.prank(_from);
        verifiedERC20.approve({spender: _caller, value: _allowance});

        vm.startPrank(_caller);

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, _caller, _allowance, _amount)
        );
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    }

    modifier whenTheAmountIsSmallerOrEqualToTheAllowance() {
        //approve the maximum amount to the spender
        vm.prank(users.alice);
        verifiedERC20.approve({spender: users.bob, value: MAX_TOKENS});
        _;
    }

    function testFuzz_WhenTheFromAddressIsTheZeroAddress(uint256 _amount, address _to)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
    {
        // It should revert with {ERC20InvalidSender}
        vm.assume(_to != address(0));
        _amount = bound(_amount, 1, MAX_TOKENS);

        address _caller = users.bob;

        vm.startPrank(_caller);
        /// @dev it's not possible to approve the zero address, so the revert is InsufficientAllowance instead of InvalidSender
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, _caller, 0, _amount));
        verifiedERC20.transferFrom({from: address(0), to: _to, value: _amount});
    }

    modifier whenTheFromAddressIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenTheToAddressIsTheZeroAddress(uint256 _amount)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheFromAddressIsNotTheZeroAddress
    {
        // It should revert with {ERC20InvalidReceiver}

        _amount = bound(_amount, 1, MAX_TOKENS);
        address _from = users.alice;
        address _to = address(0);
        address _caller = users.bob;
        vm.startPrank(_caller);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, _to));
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    }

    modifier whenTheToAddressIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenAmountIsGreaterThanFromBalance(uint256 _amount, uint256 _balance, address _to)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheFromAddressIsNotTheZeroAddress
        whenTheToAddressIsNotTheZeroAddress
    {
        // It should revert with {ERC20InsufficientBalance}
        vm.assume(_to != address(0));
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, 0, _amount - 1);
        address _from = users.alice;
        address _caller = users.bob;

        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: _from, _value: _balance});

        vm.startPrank(_caller);

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _from, _balance, _amount)
        );
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    }

    function testFuzz_WhenAmountIsSmallerOrEqualToFromBalance(uint256 _amount, uint256 _balance, address _to)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheFromAddressIsNotTheZeroAddress
        whenTheToAddressIsNotTheZeroAddress
    {
        // It should deduct the allowance
        // It should transfer the amount
        // It should emit a {Transfer} event
        vm.assume(_to != address(0));
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, _amount, MAX_TOKENS);
        address _from = users.alice;
        address _caller = users.bob;
        uint256 balanceBefore = verifiedERC20.balanceOf({account: _to});

        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: _from, _value: _balance});

        vm.startPrank(_caller);

        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer(_from, _to, _amount);
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
        assertEq(verifiedERC20.allowance({owner: _from, spender: users.bob}), MAX_TOKENS - _amount);
        assertEq(verifiedERC20.balanceOf({account: _from}), _balance - _amount);
        assertEq(verifiedERC20.balanceOf({account: _to}), balanceBefore + _amount);
    }
}
