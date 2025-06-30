// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20.t.sol";

contract MintConcreteTest is VerifiedERC20Test {
    function test_WhenTheCallerIsNotLockbox() external {
        // It should revert with {VerifiedERC20_HookRevert}
        uint256 _amount = 100;
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
        verifiedERC20.mint({_account: _account, _value: _amount});
    }

    modifier whenTheCallerIsLockbox() {
        vm.startPrank(address(lockbox));
        _;
    }

    function test_WhenTheAccountPassedIsTheZeroAddress() external whenTheCallerIsLockbox {
        // It should revert with {ERC20InvalidReceiver}
        uint256 _amount = 100;
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        verifiedERC20.mint({_account: address(0), _value: _amount});
    }

    function test_WhenTheAccountPassedIsNotTheZeroAddress() external whenTheCallerIsLockbox {
        // It should call the single permission mint hook
        // It should emit a {Transfer} event
        // It should mint the amount to the user
        uint256 _amount = 100;
        address _account = users.alice;

        /// @dev check hooks are called only once per entrypoint
        vm.expectCall({
            callee: address(singlePermissionMintHook),
            data: abi.encodeCall(IHook.check, (address(lockbox), abi.encode(_account, _amount))),
            count: 1
        });
        vm.expectEmit(address(verifiedERC20));
        emit IERC20.Transfer({from: address(0), to: _account, value: _amount});
        verifiedERC20.mint({_account: _account, _value: _amount});

        assertEq(verifiedERC20.balanceOf({account: _account}), _amount);
    }

    function testGas_mint() external whenTheCallerIsLockbox {
        // It should call the single permission mint hook
        // It should emit a {Transfer} event
        // It should mint the amount to the user
        uint256 _amount = 100;
        address _account = users.alice;

        verifiedERC20.mint({_account: _account, _value: _amount});
        vm.snapshotGasLastCall({name: "SelfVerifiedERC20_mint"});
    }
}
