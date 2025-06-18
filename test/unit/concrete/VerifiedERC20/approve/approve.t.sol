// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract ApproveConcreteTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(users.owner);
        hookRegistry.registerHook({_hook: address(beforeHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_APPROVE});
        hookRegistry.registerHook({_hook: address(afterHook), _entrypoint: IHookRegistry.Entrypoint.AFTER_APPROVE});

        verifiedERC20.activateHook({_hook: address(beforeHook)});
        verifiedERC20.activateHook({_hook: address(afterHook)});
        vm.stopPrank();
    }

    function test_WhenTheSpenderIsTheZeroAddress() external {
        // It should revert with {ERC20InvalidSpender}

        uint256 _amount = 100;
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidSpender.selector, address(0)));
        verifiedERC20.approve({spender: address(0), value: _amount});
    }

    function test_WhenTheSpenderIsNotTheZeroAddress() external {
        // It should call the before hook
        // It should call the after hook
        // It should emit an {Approval} event
        // It should set the allowance correctly

        uint256 _amount = 100;
        address _spender = users.alice;
        address _caller = users.bob;

        /// @dev check hooks are called only once per entrypoint
        vm.expectCall({
            callee: address(beforeHook),
            data: abi.encodeCall(IHook.check, (_caller, abi.encode(_spender, _amount))),
            count: 1
        });
        vm.expectCall({
            callee: address(afterHook),
            data: abi.encodeCall(IHook.check, (_caller, abi.encode(_spender, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Approval({owner: _caller, spender: _spender, value: _amount});
        vm.prank(_caller);
        verifiedERC20.approve({spender: _spender, value: _amount});

        assertEq(verifiedERC20.allowance({owner: _caller, spender: _spender}), _amount);
    }
}
