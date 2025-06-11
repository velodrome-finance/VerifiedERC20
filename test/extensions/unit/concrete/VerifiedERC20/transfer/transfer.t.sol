// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract TransferConcreteTest is VerifiedERC20Test {
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

    function test_WhenAmountIsSmallerOrEqualToBalance()
        external
        whenTheTransferIsAnIncentiveClaim
        whenTheUserIsVerified
        whenTheToAddressPassedIsNotTheZeroAddress
    {
        // It should call the self transfer hook
        // It should emit a {Transfer} event
        // It should transfer the amount
        uint256 _amount = 1000 - 1;
        address _to = users.alice;
        address _from = address(incentiveReward);
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
}
