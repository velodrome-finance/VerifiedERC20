// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseFixture.sol";

contract PermissionedERC20Test is BaseFixture {
    function setUp() public override {
        super.setUp();
        // common set up for all PermissionedERC20 tests
    }

    function test_InitialState() public view {
        assertEq(permissionedERC20.name(), "PermissionedERC20");
        assertEq(permissionedERC20.symbol(), "PermissionedRC20");
    }
}
