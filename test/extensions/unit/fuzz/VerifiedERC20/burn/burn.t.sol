// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract BurnConcreteTest is VerifiedERC20Test {
    function testFuzz_WhenTheCallerIsNotLockbox(address _caller, address _account, uint256 _amount) external {
        // It should revert with {VerifiedERC20_HookRevert}
        vm.assume(_caller != address(lockbox));
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

    modifier whenTheCallerIsLockbox() {
        vm.startPrank(address(lockbox));
        _;
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheAllowance(uint256 _amount, address _account)
        external
        whenTheCallerIsLockbox
    {
        // It should revert with {ERC20InsufficientAllowance}
        vm.assume(_account != address(0) && _account != address(lockbox));
        _amount = bound(_amount, 1, MAX_TOKENS);

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(lockbox), 0, _amount)
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    modifier whenTheAmountIsSmallerOrEqualToTheAllowance() {
        vm.prank(users.alice);
        verifiedERC20.approve({spender: address(lockbox), value: MAX_TOKENS});
        _;
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheUsersBalance(uint256 _amount, uint256 _balance)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheCallerIsLockbox
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

    function testFuzz_WhenTheAmountIsSmallerOrEqualToTheUsersBalance(uint256 _amount, uint256 _balance)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheCallerIsLockbox
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
