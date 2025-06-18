// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract TransferFuzzTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();
        deal({token: CELO, to: address(lockbox), give: MAX_TOKENS});
    }

    modifier whenTheTransferIsAnIncentiveClaim() {
        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: address(incentiveReward), _value: MAX_TOKENS});
        vm.startPrank(address(incentiveReward));
        _;
    }

    function testFuzz_WhenTheUserIsNotVerified(uint256 _amount, address _to)
        external
        whenTheTransferIsAnIncentiveClaim
    {
        // It should revert with {VerifiedERC20_HookRevert}
        vm.assume(_to != address(0));
        address _caller = address(incentiveReward);

        vm.expectRevert(
            abi.encodeWithSelector(
                IVerifiedERC20.VerifiedERC20_HookRevert.selector,
                abi.encode(
                    bytes32(
                        abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _caller, _to, _amount))
                    )
                )
            )
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    modifier whenTheUserIsVerified() {
        _;
    }

    function testFuzz_WhenTheToAddressPassedIsTheZeroAddress(uint256 _amount)
        external
        whenTheTransferIsAnIncentiveClaim
        whenTheUserIsVerified
    {
        // It should revert with {ERC20InvalidReceiver}
        address _to = address(0);
        selfPassportSBT.mint({to: users.alice, tokenId: 1});

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    modifier whenTheToAddressPassedIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenAmountIsGreaterThanBalance(uint256 _amount, address _to)
        external
        whenTheTransferIsAnIncentiveClaim
        whenTheUserIsVerified
        whenTheToAddressPassedIsNotTheZeroAddress
    {
        // It should revert with {ERC20InsufficientBalance}
        vm.assume(_to != address(0));
        selfPassportSBT.mint({to: _to, tokenId: 1});
        _amount = bound(_amount, MAX_TOKENS + 1, type(uint256).max);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector, address(incentiveReward), MAX_TOKENS, _amount
            )
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    modifier whenAmountIsSmallerOrEqualToBalance() {
        _;
    }

    function testFuzz_WhenAmountIsGreaterThanAutoUnwrapHookAllowance(uint256 _amount, address _to, uint256 _allowance)
        external
        whenAmountIsSmallerOrEqualToBalance
        whenTheUserIsVerified
        whenTheToAddressPassedIsNotTheZeroAddress
        whenTheTransferIsAnIncentiveClaim
    {
        // It should revert with {VerifiedERC20_HookRevert}
        vm.assume(_to != address(0));
        selfPassportSBT.mint({to: _to, tokenId: 1});
        _amount = bound(_amount, 1, MAX_TOKENS);
        _allowance = bound(_allowance, 0, _amount - 1);
        vm.stopPrank();
        vm.prank(_to);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: _allowance});
        vm.startPrank(address(incentiveReward));

        vm.expectRevert(
            abi.encodeWithSelector(
                IVerifiedERC20.VerifiedERC20_HookRevert.selector,
                abi.encode(
                    bytes32(
                        abi.encodeWithSelector(
                            IERC20Errors.ERC20InsufficientAllowance.selector,
                            address(autoUnwrapHook),
                            _allowance,
                            _amount
                        )
                    )
                )
            )
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    function testFuzz_WhenAmountIsSmallerOrEqualToAutoUnwrapHookAllowance(
        uint256 _amount,
        uint256 _allowance,
        address _to
    )
        external
        whenTheTransferIsAnIncentiveClaim
        whenTheUserIsVerified
        whenTheToAddressPassedIsNotTheZeroAddress
        whenAmountIsSmallerOrEqualToBalance
    {
        // It should call the self transfer hook
        // It should call the auto unwrap hook
        // It should emit a {Transfer} event
        // It should unwrap the amount to base token
        // It should transfer the unwrapped amount
        vm.assume(_to != address(0) && _to != address(incentiveReward) && _to != address(lockbox));
        _amount = bound(_amount, 1, MAX_TOKENS);
        selfPassportSBT.mint({to: _to, tokenId: 1});
        address _from = address(incentiveReward);
        _allowance = bound(_allowance, _amount, MAX_TOKENS);
        uint256 balanceCeloBefore = IERC20(CELO).balanceOf(_to);

        vm.stopPrank();
        vm.prank(_to);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: _allowance});

        vm.startPrank(address(incentiveReward));

        vm.expectCall({
            callee: address(selfTransferHook),
            data: abi.encodeCall(IHook.check, (_from, abi.encode(_from, _to, _amount))),
            count: 1
        });
        vm.expectCall({
            callee: address(autoUnwrapHook),
            data: abi.encodeCall(IHook.check, (_from, abi.encode(_from, _to, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _from, to: _to, value: _amount});
        vm.expectEmit(address(lockbox));
        emit IERC20Lockbox.Withdraw({_sender: address(autoUnwrapHook), _receiver: _to, _amount: _amount});
        verifiedERC20.transfer({to: _to, value: _amount});
        assertEq(verifiedERC20.balanceOf(_from), MAX_TOKENS - _amount);
        assertEq(verifiedERC20.balanceOf(_to), 0);
        assertEq(IERC20(CELO).balanceOf(_to), balanceCeloBefore + _amount);
        assertEq(verifiedERC20.allowance({spender: address(autoUnwrapHook), owner: _to}), _allowance - _amount);
    }

    modifier whenTheTransferIsNotAnIncentiveClaim() {
        _;
    }

    function testFuzz_WhenTheToAddressPassedIsTheZeroAddress_(uint256 _amount)
        external
        whenTheTransferIsNotAnIncentiveClaim
    {
        // It should revert with {ERC20InvalidReceiver}
        vm.prank(address(lockbox));
        address _from = users.alice;
        verifiedERC20.mint({_account: _from, _value: MAX_TOKENS});
        vm.startPrank(_from);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.transfer({to: address(0), value: _amount});
    }

    modifier whenTheToAddressPassedIsNotTheZeroAddress_() {
        _;
    }

    function testFuzz_WhenAmountIsGreaterThanBalance_(uint256 _amount, address _to)
        external
        whenTheTransferIsNotAnIncentiveClaim
        whenTheToAddressPassedIsNotTheZeroAddress_
    {
        // It should revert with {ERC20InsufficientBalance}
        vm.assume(_to != address(0));
        address _from = users.alice;
        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: _from, _value: MAX_TOKENS});
        vm.startPrank(_from);
        _amount = bound(_amount, MAX_TOKENS + 1, type(uint256).max);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _from, MAX_TOKENS, _amount)
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    function testFuzz_WhenAmountIsSmallerOrEqualToBalance_(uint256 _amount, address _to)
        external
        whenTheTransferIsNotAnIncentiveClaim
        whenTheToAddressPassedIsNotTheZeroAddress_
    {
        // It should call the self transfer hook
        // It should emit a {Transfer} event
        // It should transfer the amount
        vm.assume(_to != address(0) && _to != users.alice);
        uint256 balanceBefore = verifiedERC20.balanceOf(_to);
        address _from = users.alice;
        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: _from, _value: MAX_TOKENS});
        vm.startPrank(_from);
        _amount = bound(_amount, 1, MAX_TOKENS);
        vm.expectCall({
            callee: address(selfTransferHook),
            data: abi.encodeCall(IHook.check, (_from, abi.encode(_from, _to, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _from, to: _to, value: _amount});
        verifiedERC20.transfer({to: _to, value: _amount});
        assertEq(verifiedERC20.balanceOf(_from), MAX_TOKENS - _amount);
        assertEq(verifiedERC20.balanceOf(_to), balanceBefore + _amount);
    }
}
