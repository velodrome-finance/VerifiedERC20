// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../SinglePermissionHook.t.sol";

contract CheckFuzzTest is SinglePermissionHookTest {
    function testFuzz_WhenTheCallerIsNotAuthorized(address _caller) external {
        // It should revert with {Hook_Revert}
        vm.assume(_caller != users.owner);
        address _address;
        uint256 _amount;

        bytes memory params = abi.encode(_address, _amount);
        vm.startPrank(address(verifiedERC20));
        vm.expectRevert(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _address, _amount)));
        singlePermissionMintHook.check(_caller, params);

        vm.expectRevert(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _address, _amount)));
        singlePermissionBurnHook.check(_caller, params);
    }

    function testFuzz_WhenTheCallerIsAuthorized() external {}
}
