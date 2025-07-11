// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract BurnConcreteTest is VerifiedERC20Test {
    uint256 userBalance = 1000;

    function setUp() public override {
        super.setUp();

        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: users.alice, _value: userBalance});

        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: address(lockbox), _value: userBalance});
    }

    modifier whenTheCallerIsTheAccount() {
        _;
    }

    function test_WhenTheCallerIsNotTheLockbox() external whenTheCallerIsTheAccount {
        // It should revert with {VerifiedERC20_HookRevert}
        uint256 _amount = userBalance;
        address _account = users.alice;
        address _caller = _account;
        vm.expectRevert(
            abi.encodeWithSelector(
                IVerifiedERC20.VerifiedERC20_HookRevert.selector,
                abi.encode(
                    bytes32(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _account, _amount)))
                )
            )
        );
        vm.prank(_caller);
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    modifier whenTheCallerIsTheLockbox() {
        vm.startPrank(address(lockbox));
        _;
    }

    function test_WhenTheAmountIsGreaterThanTheUsersBalance()
        external
        whenTheCallerIsTheAccount
        whenTheCallerIsTheLockbox
    {
        // It should revert with {ERC20InsufficientBalance}
        uint256 _amount = userBalance + 1;
        address _account = address(lockbox);

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _account, userBalance, _amount)
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    function test_WhenTheAmountIsSmallerOrEqualToTheUsersBalance()
        external
        whenTheCallerIsTheAccount
        whenTheCallerIsTheLockbox
    {
        // It should call the single permission burn hook
        // It should emit a {Transfer} event
        // It should burn the amount from the user
        uint256 _amount = userBalance - 1;
        address _account = address(lockbox);

        vm.expectCall({
            callee: address(singlePermissionBurnHook),
            data: abi.encodeCall(IHook.check, (address(lockbox), abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _account, to: address(0), value: _amount});
        verifiedERC20.burn({_account: _account, _value: _amount});

        assertEq(verifiedERC20.balanceOf({account: _account}), userBalance - _amount);
    }

    modifier whenTheCallerIsNotTheAccount() {
        _;
    }

    function test_WhenTheAmountIsGreaterThanTheAllowance() external whenTheCallerIsNotTheAccount {
        // It should revert with {ERC20InsufficientAllowance}
        uint256 _amount = userBalance;
        address _account = users.alice;
        address _caller = users.charlie;

        vm.startPrank(_caller);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, _caller, 0, _amount));
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    modifier whenTheAmountIsSmallerOrEqualToTheAllowance(address _caller) {
        vm.prank(users.alice);
        verifiedERC20.approve({spender: _caller, value: userBalance + 1});
        _;
    }

    function test_WhenTheCallerIsNotTheLockbox_()
        external
        whenTheCallerIsNotTheAccount
        whenTheAmountIsSmallerOrEqualToTheAllowance(users.charlie)
    {
        // It should revert with {VerifiedERC20_HookRevert}
        uint256 _amount = userBalance;
        address _account = users.alice;
        address _caller = users.charlie;
        vm.expectRevert(
            abi.encodeWithSelector(
                IVerifiedERC20.VerifiedERC20_HookRevert.selector,
                abi.encode(
                    bytes32(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _account, _amount)))
                )
            )
        );
        vm.prank(_caller);
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    modifier whenTheCallerIsTheLockbox_() {
        vm.startPrank(address(lockbox));
        _;
    }

    function test_WhenTheAmountIsGreaterThanTheUsersBalance_()
        external
        whenTheCallerIsNotTheAccount
        whenTheAmountIsSmallerOrEqualToTheAllowance(address(lockbox))
        whenTheCallerIsTheLockbox_
    {
        // It should revert with {ERC20InsufficientBalance}
        uint256 _amount = userBalance + 1;
        address _account = users.alice;

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _account, userBalance, _amount)
        );
        verifiedERC20.burn({_account: _account, _value: _amount});
    }

    function test_WhenTheAmountIsSmallerOrEqualToTheUsersBalance_()
        external
        whenTheCallerIsNotTheAccount
        whenTheAmountIsSmallerOrEqualToTheAllowance(address(lockbox))
        whenTheCallerIsTheLockbox_
    {
        // It should call the single permission burn hook
        // It should deduct the allowance
        // It should emit a {Transfer} event
        // It should burn the amount from the user
        uint256 _amount = userBalance - 1;
        address _account = users.alice;

        vm.expectCall({
            callee: address(singlePermissionBurnHook),
            data: abi.encodeCall(IHook.check, (address(lockbox), abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: _account, to: address(0), value: _amount});
        verifiedERC20.burn({_account: _account, _value: _amount});

        assertEq(verifiedERC20.balanceOf({account: _account}), userBalance - _amount);
        assertEq(verifiedERC20.allowance({spender: address(lockbox), owner: _account}), userBalance + 1 - _amount);
    }

    function testGas_burn()
        external
        whenTheCallerIsNotTheAccount
        whenTheAmountIsSmallerOrEqualToTheAllowance(address(lockbox))
        whenTheCallerIsTheLockbox_
    {
        uint256 _amount = userBalance - 1;
        address _account = users.alice;

        verifiedERC20.burn({_account: _account, _value: _amount});

        vm.snapshotGasLastCall({name: "SelfVerifiedERC20_burn"});
    }
}
