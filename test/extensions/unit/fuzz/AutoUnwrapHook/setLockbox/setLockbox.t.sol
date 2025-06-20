// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../AutoUnwrapHook.t.sol";

contract SetLockboxFuzzTest is AutoUnwrapHookTest {
    function testFuzz_WhenTheLockboxPassedIsTheZeroAddress(address _verifiedERC20) external {
        // It should revert with {AutoUnwrapHook_ZeroAddress}
        address _lockbox = address(0);
        vm.assume(_verifiedERC20 != address(0));
        vm.expectRevert(abi.encodeWithSelector(AutoUnwrapHook.AutoUnwrapHook_ZeroAddress.selector));
        autoUnwrapHook.setLockbox({_verifiedERC20: _verifiedERC20, _lockbox: _lockbox});
    }

    modifier whenTheLockboxPassedIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenTheVerifiedERC20PassedIsTheZeroAddress(address _lockbox)
        external
        whenTheLockboxPassedIsNotTheZeroAddress
    {
        // It should revert with {AutoUnwrapHook_ZeroAddress}
        vm.assume(_lockbox != address(0));
        address _verifiedERC20 = address(0);
        vm.expectRevert(abi.encodeWithSelector(AutoUnwrapHook.AutoUnwrapHook_ZeroAddress.selector));
        autoUnwrapHook.setLockbox({_verifiedERC20: _verifiedERC20, _lockbox: _lockbox});
    }

    modifier whenTheVerifiedERC20PassedIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenTheCallerIsNotTheVerifiedERC20Owner(address _caller)
        external
        whenTheLockboxPassedIsNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should revert with {AutoUnwrapHook_NotAuthorized}
        address _lockbox = address(lockbox);
        address _verifiedERC20 = address(verifiedERC20);
        vm.assume(_caller != users.owner);
        vm.startPrank(_caller);
        vm.expectRevert(
            abi.encodeWithSelector(
                AutoUnwrapHook.AutoUnwrapHook_NotAuthorized.selector, _caller, _verifiedERC20, _lockbox
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
    }
}
