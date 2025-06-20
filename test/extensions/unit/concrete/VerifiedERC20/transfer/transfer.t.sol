// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract TransferConcreteTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();
        deal({token: CELO, to: address(lockbox), give: 1000 - 1});
    }

    modifier whenTheTransferIsAnIncentiveClaim() {
        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: address(incentiveReward), _value: 1000});
        vm.startPrank(address(incentiveReward));
        _;
    }

    function test_WhenTheUserIsNotVerified() external whenTheTransferIsAnIncentiveClaim {
        // It should revert with {VerifiedERC20_HookRevert}
        uint256 _amount = 100;
        address _to = users.alice;
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
        selfPassportSBT.mint({to: users.alice, tokenId: 1});
        _;
    }

    function test_WhenTheToAddressPassedIsTheZeroAddress()
        external
        whenTheTransferIsAnIncentiveClaim
        whenTheUserIsVerified
    {
        // It should revert with {ERC20InvalidReceiver}
        uint256 _amount = 100;
        address _to = address(0);
        address _caller = address(incentiveReward);

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    modifier whenTheToAddressPassedIsNotTheZeroAddress() {
        _;
    }

    function test_WhenAmountIsGreaterThanBalance()
        external
        whenTheTransferIsAnIncentiveClaim
        whenTheUserIsVerified
        whenTheToAddressPassedIsNotTheZeroAddress
    {
        // It should revert with {ERC20InsufficientBalance}
        uint256 _amount = 1000 + 1;
        address _to = users.alice;
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector, address(incentiveReward), 1000, _amount
            )
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    modifier whenAmountIsSmallerOrEqualToBalance() {
        _;
    }

    function test_WhenAmountIsGreaterThanAutoUnwrapHookAllowance()
        external
        whenTheTransferIsAnIncentiveClaim
        whenTheUserIsVerified
        whenTheToAddressPassedIsNotTheZeroAddress
        whenAmountIsSmallerOrEqualToBalance
    {
        // It should revert with {VerifiedERC20_HookRevert}
        uint256 _amount = 1000 - 1;
        address _to = users.alice;
        vm.expectRevert(
            abi.encodeWithSelector(
                IVerifiedERC20.VerifiedERC20_HookRevert.selector,
                abi.encode(
                    bytes32(
                        abi.encodeWithSelector(
                            IERC20Errors.ERC20InsufficientAllowance.selector, address(autoUnwrapHook), 0, _amount
                        )
                    )
                )
            )
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    function test_WhenAmountIsSmallerOrEqualToAutoUnwrapHookAllowance()
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
        uint256 _amount = 1000 - 1;
        address _to = users.alice;
        address _from = address(incentiveReward);

        vm.stopPrank();
        vm.prank(_to);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: 1000 + 1});
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
        assertEq(verifiedERC20.balanceOf(_from), 1000 - _amount);
        assertEq(verifiedERC20.balanceOf(_to), 0);
        assertEq(IERC20(CELO).balanceOf(_to), _amount);
        assertEq(verifiedERC20.allowance({spender: address(autoUnwrapHook), owner: _to}), 1000 + 1 - _amount);
    }

    modifier whenTheTransferIsNotAnIncentiveClaim() {
        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: users.alice, _value: 1000});
        vm.startPrank(users.alice);
        _;
    }

    function test_WhenTheToAddressPassedIsTheZeroAddress_() external whenTheTransferIsNotAnIncentiveClaim {
        // It should revert with {ERC20InvalidReceiver}
        uint256 _amount = 100;
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.transfer({to: address(0), value: _amount});
    }

    modifier whenTheToAddressPassedIsNotTheZeroAddress_() {
        _;
    }

    function test_WhenAmountIsGreaterThanBalance_()
        external
        whenTheTransferIsNotAnIncentiveClaim
        whenTheToAddressPassedIsNotTheZeroAddress_
    {
        // It should revert with {ERC20InsufficientBalance}
        uint256 _amount = 1000 + 1;
        address _to = users.bob;
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, users.alice, 1000, _amount)
        );
        verifiedERC20.transfer({to: _to, value: _amount});
    }

    function test_WhenAmountIsSmallerOrEqualToBalance_()
        external
        whenTheTransferIsNotAnIncentiveClaim
        whenTheToAddressPassedIsNotTheZeroAddress_
    {
        // It should call the self transfer hook
        // It should emit a {Transfer} event
        // It should transfer the amount
        uint256 _amount = 1000 - 1;
        address _to = users.bob;
        address _from = users.alice;
        vm.expectCall({
            callee: address(selfTransferHook),
            data: abi.encodeCall(IHook.check, (_from, abi.encode(_from, _to, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _from, to: _to, value: _amount});
        verifiedERC20.transfer({to: _to, value: _amount});
        assertEq(verifiedERC20.balanceOf(_from), 1000 - _amount);
        assertEq(verifiedERC20.balanceOf(_to), _amount);
    }

    function testGas_transfer()
        external
        whenTheTransferIsNotAnIncentiveClaim
        whenTheToAddressPassedIsNotTheZeroAddress_
    {
        // It should call the self transfer hook
        // It should emit a {Transfer} event
        // It should transfer the amount
        uint256 _amount = 1000 - 1;
        address _to = users.bob;
        address _from = users.alice;
        verifiedERC20.transfer({to: _to, value: _amount});
        vm.snapshotGasLastCall({name: "SelfVerifiedERC20_transfer"});
    }
}
