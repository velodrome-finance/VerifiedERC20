// SPDX-License-Identifier: MIT
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

    function _deployHooks() internal override {
        beforeHook = new MockSuccessTransferHook();
        afterHook = new MockSuccessTransferHook();

        vm.label(address(beforeHook), "beforeHook");
        vm.label(address(afterHook), "afterHook");
    }

    function test_WhenTheAmountIsGreaterThanTheAllowance() external {
        // It should revert with {ERC20InsufficientAllowance}
        uint256 _amount = 1000;
        address _from = users.alice;
        address _to = users.bob;
        address _caller = users.charlie;
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, _caller, 0, _amount));
        vm.prank(_caller);
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
    }

    modifier whenTheAmountIsSmallerOrEqualToTheAllowance(uint256 _amount) {
        vm.prank(users.alice);
        verifiedERC20.approve({spender: users.bob, value: _amount});
        _;
    }

    function test_WhenTheFromAddressIsTheZeroAddress() external whenTheAmountIsSmallerOrEqualToTheAllowance(0) {
        // It should revert with {ERC20InvalidSender}
        uint256 _amount = 1000;
        address _to = users.bob;
        address _caller = users.bob;
        /// @dev it's not possible to approve the zero address, so the revert is InsufficientAllowance instead of InvalidSender
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, _caller, 0, _amount));
        vm.prank(_caller);
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
        address _caller = users.bob;
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        vm.prank(_caller);
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
        address _caller = users.bob;

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, _from, 1000, _amount));
        vm.prank(_caller);
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
        address _caller = users.bob;
        assertEq(verifiedERC20.allowance({owner: _from, spender: _caller}), _amount);

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
        vm.prank(_caller);
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
        assertEq(verifiedERC20.allowance({owner: _from, spender: _caller}), 0);
        assertEq(verifiedERC20.balanceOf({account: _from}), 1000 - _amount);
        assertEq(verifiedERC20.balanceOf({account: _to}), _amount);
    }

    function testGas_transferFrom()
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
        address _caller = users.bob;

        vm.prank(_caller);
        verifiedERC20.transferFrom({from: _from, to: _to, value: _amount});
        vm.snapshotGasLastCall({name: "VerifiedERC20_transferFrom"});
    }
}
