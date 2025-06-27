// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract BurnConcreteTest is VerifiedERC20Test {
    modifier whenTheCallerIsTheAccount() {
        _;
    }

    function testFuzz_WhenTheCallerIsNotTheLockbox(address _caller, uint256 _amount)
        external
        whenTheCallerIsTheAccount
    {
        // It should revert with {VerifiedERC20_HookRevert}
        vm.assume(_caller != address(lockbox));
        address _account = _caller;
        vm.startPrank(_caller);
        vm.expectRevert(
            abi.encodeWithSelector(
                IVerifiedERC20.VerifiedERC20_HookRevert.selector,
                abi.encode(
                    bytes32(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _account, _amount)))
                )
            )
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    modifier whenTheCallerIsTheLockbox() {
        vm.startPrank(address(lockbox));
        _;
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheUsersBalance(uint256 _amount, uint256 _balance)
        external
        whenTheCallerIsTheAccount
        whenTheCallerIsTheLockbox
    {
        // It should revert with {ERC20InsufficientBalance}
        address _account = address(lockbox);
        _amount = bound(uint256(_amount), 1, MAX_TOKENS);
        _balance = bound(_balance, 0, _amount - 1);
        verifiedERC20.mint({_account: _account, _value: _balance});

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _account, _balance, _amount)
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    function testFuzz_WhenTheAmountIsSmallerOrEqualToTheUsersBalance(uint256 _amount, uint256 _balance)
        external
        whenTheCallerIsTheAccount
        whenTheCallerIsTheLockbox
    {
        // It should call the single permission burn hook
        // It should emit a {Transfer} event
        // It should burn the amount from the user
        address _account = address(lockbox);
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, _amount, MAX_TOKENS);
        verifiedERC20.mint({_account: _account, _value: _balance});

        vm.expectCall({
            callee: address(singlePermissionBurnHook),
            data: abi.encodeCall(IHook.check, (address(lockbox), abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _account, to: address(0), value: _amount});
        verifiedERC20.burn({_account: _account, _value: _amount});

        assertEq(verifiedERC20.balanceOf({account: _account}), _balance - _amount);
    }

    modifier whenTheCallerIsNotTheAccount(address _caller, address _account) {
        vm.assume(_account != address(0) && _caller != address(0) && _caller != _account);
        _;
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheAllowance(
        uint256 _amount,
        uint256 _allowance,
        address _account,
        address _caller
    ) external whenTheCallerIsNotTheAccount(_caller, _account) {
        // It should revert with {ERC20InsufficientAllowance}
        _amount = bound(_amount, 1, MAX_TOKENS);

        _allowance = bound(_allowance, 0, _amount - 1);
        vm.prank(_account);
        verifiedERC20.approve({spender: _caller, value: _allowance});

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, _caller, _allowance, _amount)
        );
        vm.prank(_caller);
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    modifier whenTheAmountIsSmallerOrEqualToTheAllowance() {
        vm.prank(users.alice);
        verifiedERC20.approve({spender: address(lockbox), value: MAX_TOKENS});
        _;
    }

    function testFuzz_WhenTheCallerIsNotTheLockbox_(address _caller, address _account, uint256 _amount)
        external
        whenTheCallerIsNotTheAccount(_caller, _account)
        whenTheAmountIsSmallerOrEqualToTheAllowance
    {
        // It should revert with {VerifiedERC20_HookRevert}
        vm.assume(_caller != address(lockbox));

        vm.prank(_account);
        verifiedERC20.approve({spender: _caller, value: MAX_TOKENS});

        _amount = bound(_amount, 1, MAX_TOKENS);

        vm.startPrank(_caller);
        vm.expectRevert(
            abi.encodeWithSelector(
                IVerifiedERC20.VerifiedERC20_HookRevert.selector,
                abi.encode(
                    bytes32(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _account, _amount)))
                )
            )
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    modifier whenTheCallerIsTheLockbox_() {
        vm.startPrank(address(lockbox));
        _;
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheUsersBalance_(uint256 _amount, uint256 _balance)
        external
        whenTheCallerIsNotTheAccount(address(lockbox), users.alice)
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheCallerIsTheLockbox_
    {
        // It should revert with {ERC20InsufficientBalance}
        address _account = users.alice;
        _amount = bound(uint256(_amount), 1, MAX_TOKENS);
        _balance = bound(_balance, 0, _amount - 1);
        verifiedERC20.mint({_account: _account, _value: _balance});

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _account, _balance, _amount)
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    function testFuzz_WhenTheAmountIsSmallerOrEqualToTheUsersBalance_(uint256 _amount, uint256 _balance)
        external
        whenTheCallerIsNotTheAccount(address(lockbox), users.alice)
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheCallerIsTheLockbox_
    {
        // It should call the single permission burn hook
        // It should deduct the allowance
        // It should emit a {Transfer} event
        // It should burn the amount from the user
        address _account = users.alice;
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, _amount, MAX_TOKENS);
        verifiedERC20.mint({_account: _account, _value: _balance});

        uint256 _allowance = verifiedERC20.allowance({owner: _account, spender: address(lockbox)});

        vm.expectCall({
            callee: address(singlePermissionBurnHook),
            data: abi.encodeCall(IHook.check, (address(lockbox), abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _account, to: address(0), value: _amount});
        verifiedERC20.burn({_account: _account, _value: _amount});

        assertEq(verifiedERC20.balanceOf({account: _account}), _balance - _amount);
        assertEq(verifiedERC20.allowance({spender: address(lockbox), owner: _account}), _allowance - _amount);
    }
}
