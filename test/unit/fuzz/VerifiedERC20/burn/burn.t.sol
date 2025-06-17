// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract BurnFuzzTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(users.owner);
        hookRegistry.registerHook({_hook: address(beforeHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_BURN});
        hookRegistry.registerHook({_hook: address(afterHook), _entrypoint: IHookRegistry.Entrypoint.AFTER_BURN});

        verifiedERC20.activateHook({_hook: address(beforeHook)});
        verifiedERC20.activateHook({_hook: address(afterHook)});
        vm.stopPrank();
    }

    function testFuzz_WhenTheAccountPassedIsTheZeroAddress(uint256 _amount) external {
        // It should revert with {ERC20InvalidSender}
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidSender.selector, address(0)));
        verifiedERC20.burn({_account: address(0), _value: _amount});
    }

    modifier whenTheAccountPassedIsNotTheZeroAddress() {
        _;
    }

    modifier whenTheCallerIsNotTheAccount() {
        _;
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheAllowance(
        uint256 _amount,
        uint256 _allowance,
        address _caller,
        address _account
    ) external whenTheAccountPassedIsNotTheZeroAddress whenTheCallerIsNotTheAccount {
        // It should revert with {ERC20InsufficientAllowance}
        vm.assume(_caller != _account && _account != address(0) && _caller != address(0));
        _amount = bound(_amount, 1, MAX_TOKENS);
        _allowance = bound(_allowance, 0, _amount - 1);
        vm.prank(_account);
        verifiedERC20.approve({spender: _caller, value: _allowance});

        vm.startPrank(_caller);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, _caller, _allowance, _amount)
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    modifier whenTheAmountIsSmallerOrEqualToTheAllowance() {
        vm.prank(users.alice);
        verifiedERC20.approve({spender: users.bob, value: MAX_TOKENS});
        _;
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheUsersBalance(uint256 _amount, uint256 _balance)
        external
        whenTheAccountPassedIsNotTheZeroAddress
        whenTheCallerIsNotTheAccount
        whenTheAmountIsSmallerOrEqualToTheAllowance
    {
        // It should revert with {ERC20InsufficientBalance}
        _amount = bound(_amount, 1, MAX_TOKENS);
        address _caller = users.bob;
        address _account = users.alice;
        _balance = bound(_balance, 0, _amount - 1);
        verifiedERC20.mint({_account: _account, _value: _balance});

        vm.startPrank(_caller);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _account, _balance, _amount)
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    function testFuzz_WhenTheAmountIsSmallerOrEqualToTheUsersBalance(uint256 _amount, uint256 _balance)
        external
        whenTheAccountPassedIsNotTheZeroAddress
        whenTheCallerIsNotTheAccount
        whenTheAmountIsSmallerOrEqualToTheAllowance
    {
        // It should call the before hook
        // It should call the after hook
        // It should deduct the allowance
        // It should emit a {Transfer} event
        // It should burn the amount from the user
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, _amount, MAX_TOKENS);
        address _account = users.alice;
        address _caller = users.bob;
        verifiedERC20.mint({_account: _account, _value: _balance});

        vm.startPrank(_caller);
        /// @dev check hooks are called only once per entrypoint
        vm.expectCall({
            callee: address(beforeHook),
            data: abi.encodeCall(IHook.check, (_caller, abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectCall({
            callee: address(afterHook),
            data: abi.encodeCall(IHook.check, (_caller, abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _account, to: address(0), value: _amount});
        verifiedERC20.burn({_account: _account, _value: _amount});

        assertEq(verifiedERC20.balanceOf({account: _account}), _balance - _amount);
        assertEq(verifiedERC20.allowance({spender: _caller, owner: _account}), MAX_TOKENS - _amount);
    }

    modifier whenTheCallerIsTheAccount() {
        _;
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheUsersBalance_(uint256 _amount, uint256 _balance)
        external
        whenTheAccountPassedIsNotTheZeroAddress
        whenTheCallerIsTheAccount
    {
        // It should revert with {ERC20InsufficientBalance}
        _amount = bound(_amount, 1, MAX_TOKENS);
        address _caller = users.alice;
        address _account = users.alice;
        _balance = bound(_balance, 0, _amount - 1);
        verifiedERC20.mint({_account: _account, _value: _balance});

        vm.startPrank(_caller);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _account, _balance, _amount)
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    function testFuzz_WhenTheAmountIsSmallerOrEqualToTheUsersBalance_(uint256 _amount, uint256 _balance)
        external
        whenTheAccountPassedIsNotTheZeroAddress
        whenTheCallerIsTheAccount
    {
        // It should call the before hook
        // It should call the after hook
        // It should emit a {Transfer} event
        // It should burn the amount from the user
        address _account = users.alice;
        address _caller = users.alice;
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, _amount, MAX_TOKENS);
        verifiedERC20.mint({_account: _account, _value: _balance});

        vm.startPrank(_caller);
        /// @dev check hooks are called only once per entrypoint
        vm.expectCall({
            callee: address(beforeHook),
            data: abi.encodeCall(IHook.check, (_caller, abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectCall({
            callee: address(afterHook),
            data: abi.encodeCall(IHook.check, (_caller, abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _account, to: address(0), value: _amount});
        verifiedERC20.burn({_account: _account, _value: _amount});

        assertEq(verifiedERC20.balanceOf({account: _account}), _balance - _amount);
    }
}
