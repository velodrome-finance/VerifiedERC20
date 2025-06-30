// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../AutoUnwrapHook.t.sol";

contract SetLockboxConcreteTest is AutoUnwrapHookTest {
    function test_WhenTheLockboxPassedIsTheZeroAddress() external {
        // It should revert with {AutoUnwrapHook_ZeroAddress}
        address _lockbox = address(0);
        vm.expectRevert(abi.encodeWithSelector(AutoUnwrapHook.AutoUnwrapHook_ZeroAddress.selector));
        autoUnwrapHook.setLockbox({_verifiedERC20: address(verifiedERC20), _lockbox: _lockbox});
    }

    modifier whenTheLockboxPassedIsNotTheZeroAddress() {
        _;
    }

    function test_WhenTheVerifiedERC20PassedIsTheZeroAddress() external whenTheLockboxPassedIsNotTheZeroAddress {
        // It should revert with {AutoUnwrapHook_ZeroAddress}
        address _lockbox = address(lockbox);
        address _verifiedERC20 = address(0);
        vm.expectRevert(abi.encodeWithSelector(AutoUnwrapHook.AutoUnwrapHook_ZeroAddress.selector));
        autoUnwrapHook.setLockbox({_verifiedERC20: _verifiedERC20, _lockbox: _lockbox});
    }

    modifier whenTheVerifiedERC20PassedIsNotTheZeroAddress() {
        _;
    }

    function test_WhenTheCallerIsNotTheVerifiedERC20Owner()
        external
        whenTheLockboxPassedIsNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should revert with {AutoUnwrapHook_NotAuthorized}
        address _lockbox = address(lockbox);
        address _verifiedERC20 = address(verifiedERC20);
        vm.startPrank(users.charlie);
        vm.expectRevert(
            abi.encodeWithSelector(
                AutoUnwrapHook.AutoUnwrapHook_NotAuthorized.selector, users.charlie, _verifiedERC20, _lockbox
            )
        );
        autoUnwrapHook.setLockbox({_verifiedERC20: _verifiedERC20, _lockbox: _lockbox});
    }

    function test_WhenTheCallerIsTheVerifiedERC20Owner()
        external
        whenTheLockboxPassedIsNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should set the lockbox mapping
        // It should emit a {LockboxSet} event
        address _lockbox = users.alice;
        address _verifiedERC20 = address(verifiedERC20);

        vm.startPrank(users.owner);
        vm.expectEmit(address(autoUnwrapHook));
        emit AutoUnwrapHook.LockboxSet({verifiedERC20: _verifiedERC20, lockbox: _lockbox});
        autoUnwrapHook.setLockbox({_verifiedERC20: _verifiedERC20, _lockbox: _lockbox});

        assertEq(autoUnwrapHook.lockbox({_verifiedERC20: _verifiedERC20}), _lockbox);
    }

    function testGas_setLockbox()
        external
        whenTheLockboxPassedIsNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should set the lockbox mapping
        // It should emit a {LockboxSet} event
        address _lockbox = users.alice;
        address _verifiedERC20 = address(verifiedERC20);

        vm.startPrank(users.owner);
        autoUnwrapHook.setLockbox({_verifiedERC20: _verifiedERC20, _lockbox: _lockbox});
        vm.snapshotGasLastCall({name: "AutoUnwrapHook_setLockbox"});
    }
}
