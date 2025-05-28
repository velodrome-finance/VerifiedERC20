// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseFixture.sol";

contract VerifiedERC20Test is BaseFixture {
    function setUp() public override {
        super.setUp();
        // common set up for all VerifiedERC20 tests
    }

    function test_InitialState() public view {
        assertEq(verifiedERC20.name(), "VerifiedERC20");
        assertEq(verifiedERC20.symbol(), "VerifiedRC20");
    }
}
