// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract ApproveFuzzTest is VerifiedERC20Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(users.owner);
        hookRegistry.registerHook({_hook: address(beforeHook), _entrypoint: IHookRegistry.Entrypoint.BEFORE_APPROVE});
        hookRegistry.registerHook({_hook: address(afterHook), _entrypoint: IHookRegistry.Entrypoint.AFTER_APPROVE});

        verifiedERC20.activateHook({_hook: address(beforeHook)});
        verifiedERC20.activateHook({_hook: address(afterHook)});
        vm.stopPrank();
    }

    function testFuzz_WhenTheSpenderIsTheZeroAddress(uint256 _amount) external {
        // It should revert with {ERC20InvalidSpender}

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidSpender.selector, address(0)));
        verifiedERC20.approve({spender: address(0), value: _amount});
    }

    function testFuzz_WhenTheSpenderIsNotTheZeroAddress(uint256 _amount, address _spender) external {
        // It should call the before hook
        // It should call the after hook
        // It should emit an {Approval} event
        // It should set the allowance correctly

        vm.assume(_spender != address(0));
        /// @dev check hooks are called only once per entrypoint
        vm.expectCall({
            callee: address(beforeHook),
            data: abi.encodeCall(IHook.check, (address(this), abi.encode(_spender, _amount))),
            count: 1
        });
        vm.expectCall({
            callee: address(afterHook),
            data: abi.encodeCall(IHook.check, (address(this), abi.encode(_spender, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Approval({owner: address(this), spender: _spender, value: _amount});
        verifiedERC20.approve({spender: _spender, value: _amount});

        assertEq(verifiedERC20.allowance({owner: address(this), spender: _spender}), _amount);
    }
}
