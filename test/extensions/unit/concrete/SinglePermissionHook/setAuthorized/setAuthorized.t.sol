// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../SinglePermissionHook.t.sol";

contract SetAuthorizedConcreteTest is SinglePermissionHookTest {
    function test_WhenTheAuthorizedPassedIsTheZeroAddress() external {
        // It should revert with {SinglePermissionHook_ZeroAddress}
        address _authorized = address(0);
        vm.expectRevert(abi.encodeWithSelector(SinglePermissionHook.SinglePermissionHook_ZeroAddress.selector));
        singlePermissionMintHook.setAuthorized({_verifiedERC20: address(verifiedERC20), _authorized: _authorized});

        vm.expectRevert(abi.encodeWithSelector(SinglePermissionHook.SinglePermissionHook_ZeroAddress.selector));
        singlePermissionBurnHook.setAuthorized({_verifiedERC20: address(verifiedERC20), _authorized: _authorized});
    }

    modifier whenTheAuthorizedPassedInNotTheZeroAddress() {
        _;
    }

    function test_WhenTheVerifiedERC20PassedIsTheZeroAddress() external whenTheAuthorizedPassedInNotTheZeroAddress {
        // It should revert with {SinglePermissionHook_ZeroAddress}
        address _authorized = users.alice;
        address _verifiedERC20 = address(0);
        vm.expectRevert(abi.encodeWithSelector(SinglePermissionHook.SinglePermissionHook_ZeroAddress.selector));
        singlePermissionMintHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});

        vm.expectRevert(abi.encodeWithSelector(SinglePermissionHook.SinglePermissionHook_ZeroAddress.selector));
        singlePermissionBurnHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});
    }

    modifier whenTheVerifiedERC20PassedIsNotTheZeroAddress() {
        _;
    }

    function test_WhenTheCallerIsNotTheVerifiedERC20Owner()
        external
        whenTheAuthorizedPassedInNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should revert with {SinglePermissionHook_NotAuthorized}
        address _authorized = users.alice;
        address _verifiedERC20 = address(verifiedERC20);
        vm.startPrank(users.charlie);
        vm.expectRevert(
            abi.encodeWithSelector(
                SinglePermissionHook.SinglePermissionHook_NotAuthorized.selector,
                users.charlie,
                _verifiedERC20,
                _authorized
            )
        );
        singlePermissionMintHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});

        vm.expectRevert(
            abi.encodeWithSelector(
                SinglePermissionHook.SinglePermissionHook_NotAuthorized.selector,
                users.charlie,
                _verifiedERC20,
                _authorized
            )
        );
        singlePermissionBurnHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});
    }

    function test_WhenTheCallerIsTheVerifiedERC20Owner()
        external
        whenTheAuthorizedPassedInNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should call set the authorized mapping
        // It should emit a {AuthorizedSet} event
        address _authorized = users.alice;
        address _verifiedERC20 = address(verifiedERC20);

        vm.startPrank(users.owner);
        vm.expectEmit(address(singlePermissionMintHook));
        emit SinglePermissionHook.AuthorizedSet({verifiedERC20: _verifiedERC20, authorized: _authorized});
        singlePermissionMintHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});

        vm.expectEmit(address(singlePermissionBurnHook));
        emit SinglePermissionHook.AuthorizedSet({verifiedERC20: _verifiedERC20, authorized: _authorized});
        singlePermissionBurnHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});

        assertEq(singlePermissionMintHook.authorized({_verifiedERC20: _verifiedERC20}), users.alice);
        assertEq(singlePermissionBurnHook.authorized({_verifiedERC20: _verifiedERC20}), users.alice);
    }

    function testGas_setAuthorized()
        external
        whenTheAuthorizedPassedInNotTheZeroAddress
        whenTheVerifiedERC20PassedIsNotTheZeroAddress
    {
        // It should call set the authorized mapping
        // It should emit a {AuthorizedSet} event
        address _authorized = users.alice;
        address _verifiedERC20 = address(verifiedERC20);

        vm.startPrank(users.owner);
        singlePermissionMintHook.setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});
        vm.snapshotGasLastCall({name: "SinglePermissionHook_setAuthorized"});
    }
}
