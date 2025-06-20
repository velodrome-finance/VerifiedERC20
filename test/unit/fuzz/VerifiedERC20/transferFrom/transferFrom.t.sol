// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract TransferFromFuzzTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(users.owner);
        hookRegistry.registerHook({_hook: address(beforeHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER});
        hookRegistry.registerHook({_hook: address(afterHook), _entrypoint: IHookRegistry.Entrypoint.AFTER_TRANSFER});

        verifiedERC20.activateHook({_hook: address(beforeHook)});
        verifiedERC20.activateHook({_hook: address(afterHook)});
        vm.stopPrank();
    }

    function _deployHooks() internal override {
        beforeHook = new MockSuccessTransferHook();
        afterHook = new MockSuccessTransferHook();

        vm.label(address(beforeHook), "beforeHook");
        vm.label(address(afterHook), "afterHook");
    }

    function testFuzz_WhenTheAmountIsGreaterThanTheAllowance(
        uint256 _amount,
        uint256 _allowance,
        address _from,
        address _to,
        address _caller
    ) external {
        // It should revert with {ERC20InsufficientAllowance}
        vm.assume(_to != address(0) && _from != address(0) && _caller != address(0));
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
        _;
    }

    function testFuzz_WhenTheFromAddressIsTheZeroAddress(uint256 _amount)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
    {
        // It should revert with {ERC20InvalidSender}
        _amount = bound(_amount, 1, MAX_TOKENS);
        address _to = users.bob;
        address _caller = users.charlie;

        /// @dev it's not possible to approve the zero address, so the revert is InsufficientAllowance instead of InvalidSender
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, _caller, 0, _amount));
        vm.prank(_caller);
        verifiedERC20.transferFrom({from: address(0), to: _to, value: _amount});
    }

    modifier whenTheFromAddressIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenTheToAddressIsTheZeroAddress(uint256 _amount, uint256 _allowance)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheFromAddressIsNotTheZeroAddress
    {
        // It should revert with {ERC20InvalidReceiver}
        _amount = bound(_amount, 1, MAX_TOKENS);
        address _from = users.alice;

        _allowance = bound(_allowance, _amount, MAX_TOKENS);
        vm.prank(users.alice);
        verifiedERC20.approve({spender: users.bob, value: _allowance});

        vm.startPrank(users.bob);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.transferFrom({from: _from, to: address(0), value: _amount});
    }

    modifier whenTheToAddressIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenAmountIsGreaterThanFromBalance(uint256 _amount, uint256 _balance)
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheFromAddressIsNotTheZeroAddress
        whenTheToAddressIsNotTheZeroAddress
    {
        // It should revert with {ERC20InsufficientBalance}
        _amount = bound(_amount, 1, MAX_TOKENS);
        _balance = bound(_balance, 0, _amount - 1);
        address _from = users.alice;
        address _to = users.bob;
        address _caller = users.bob;
        verifiedERC20.mint({_account: _from, _value: _balance});

        vm.prank(_from);
        verifiedERC20.approve({spender: _caller, value: _amount});

        vm.startPrank(_caller);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _from, _balance, _amount)
        );
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    }

    function testFuzz_WhenAmountIsSmallerOrEqualToFromBalance(
        uint256 _amount,
        uint256 _balance,
        address _to,
        address _caller,
        uint256 _allowance
    )
        external
        whenTheAmountIsSmallerOrEqualToTheAllowance
        whenTheFromAddressIsNotTheZeroAddress
        whenTheToAddressIsNotTheZeroAddress
    {
        // It should call the before hook
        // It should deduct the allowance
        // It should transfer the amount
        // It should call the after hook
        // It should emit a {Transfer} event
        vm.assume(_to != address(0) && _caller != address(0));
        _amount = bound(_amount, 1, MAX_TOKENS);
        address _from = users.alice;
        _balance = bound(_balance, _amount, MAX_TOKENS);
        verifiedERC20.mint({_account: _from, _value: _balance});

        _allowance = bound(_allowance, _amount, MAX_TOKENS);
        vm.prank(_from);
        verifiedERC20.approve({spender: _caller, value: _allowance});

        vm.startPrank(_caller);
        /// @dev check hooks are called only once per entrypoint
        vm.expectCall({
            callee: address(beforeHook),
            data: abi.encodeCall(IHook.check, (_caller, abi.encode(_from, _to, _amount))),
            count: 1
        });
        vm.expectCall({
            callee: address(afterHook),
            data: abi.encodeCall(IHook.check, (_caller, abi.encode(_from, _to, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer(_from, _to, _amount);
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
        assertEq(verifiedERC20.allowance({owner: _from, spender: _caller}), _allowance - _amount);
        assertEq(verifiedERC20.balanceOf({account: _from}), _balance - _amount);
        assertEq(verifiedERC20.balanceOf({account: _to}), _amount);
    }
}
