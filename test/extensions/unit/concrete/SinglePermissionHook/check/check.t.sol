// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../SinglePermissionHook.t.sol";

contract CheckConcreteTest is SinglePermissionHookTest {
    function test_WhenTheCallerIsNotAuthorized() external {
        // It should revert with {Hook_Revert}
        address _caller = users.charlie;
        address _address;
        uint256 _amount;

        bytes memory params = abi.encode(_address, _amount);
        vm.expectRevert(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _address, _amount)));
        singlePermissionMintHook.check(_caller, params);

        vm.expectRevert(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _address, _amount)));
        singlePermissionBurnHook.check(_caller, params);
    }

    function test_WhenTheCallerIsAuthorized() external {
        // It should do nothing
        address _caller = address(lockbox);
        address _address;
        uint256 _amount;

        vm.startPrank(address(verifiedERC20));
        bytes memory params = abi.encode(_address, _amount);
        singlePermissionMintHook.check(_caller, params);
        singlePermissionBurnHook.check(_caller, params);
    }

    function testGas_check() external {
        // It should do nothing
        address _caller = address(lockbox);
        address _address;
        uint256 _amount;

        vm.startPrank(address(verifiedERC20));
        bytes memory params = abi.encode(_address, _amount);
        singlePermissionMintHook.check(_caller, params);
        vm.snapshotGasLastCall({name: "SinglePermissionHook_check"});
    }
}
