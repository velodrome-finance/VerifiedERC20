// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../SinglePermissionHook.t.sol";

contract SetAuthorizedFuzzTest is SinglePermissionHookTest {
    function testFuzz_WhenTheAuthorizedPassedIsTheZeroAddress(address _verifiedERC20) external {
        // It should revert with {SinglePermissionHook_ZeroAddress}
        vm.assume(_verifiedERC20 != address(0));
        address _authorized = address(0);
        vm.expectRevert(abi.encodeWithSelector(SinglePermissionHook.SinglePermissionHook_ZeroAddress.selector));
        singlePermissionMintHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});

        vm.expectRevert(abi.encodeWithSelector(SinglePermissionHook.SinglePermissionHook_ZeroAddress.selector));
        singlePermissionBurnHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});
    }

    modifier whenTheAuthorizedPassedIsNotTheZeroAddress() {
        _;
    }

    function testFuzz_WhenTheVerifiedERC20PassedIsTheZeroAddress(address _authorized)
        external
        whenTheAuthorizedPassedIsNotTheZeroAddress
    {
        // It should revert with {SinglePermissionHook_ZeroAddress}
        vm.assume(_authorized != address(0));
        address _verifiedERC20 = address(0);
        vm.expectRevert(abi.encodeWithSelector(SinglePermissionHook.SinglePermissionHook_ZeroAddress.selector));
        singlePermissionMintHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});

        vm.expectRevert(abi.encodeWithSelector(SinglePermissionHook.SinglePermissionHook_ZeroAddress.selector));
        singlePermissionBurnHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});
    }

    modifier whenTheVerifiedERC20PassedIsNotTheZeroAddress() {
        _;
    }

    function test_WhenTheCallerIsNotTheVerifiedERC20Owner(address _caller)
        external
        whenTheAuthorizedPassedIsNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should revert with {SinglePermissionHook_NotAuthorized}
        address _authorized = users.alice;
        address _verifiedERC20 = address(verifiedERC20);
        vm.assume(_caller != users.owner);
        vm.startPrank(_caller);
        vm.expectRevert(
            abi.encodeWithSelector(
                SinglePermissionHook.SinglePermissionHook_NotAuthorized.selector, _caller, _verifiedERC20, _authorized
            )
        );
        singlePermissionMintHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});

        vm.expectRevert(
            abi.encodeWithSelector(
                SinglePermissionHook.SinglePermissionHook_NotAuthorized.selector, _caller, _verifiedERC20, _authorized
            )
        );
        singlePermissionBurnHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});
    }

    function testFuzz_WhenTheCallerIsTheVerifiedERC20Owner()
        external
        whenTheAuthorizedPassedIsNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should call set the authorized mapping
        // It should emit a {AuthorizedSet} event
    }
}
