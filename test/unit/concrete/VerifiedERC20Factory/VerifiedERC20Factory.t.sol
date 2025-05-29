// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseFixture.sol";

contract VerifiedERC20FactoryTest is BaseFixture {
    function test_InitialState() public view {
        assertEq(verifiedERC20Factory.hookRegistry(), hookRegistry);
        /// @dev first VerifiedERC20 deployed in BaseFixture
        assertEq(verifiedERC20Factory.getVerifiedERC20Count(), 1);
        assertEq(verifiedERC20Factory.getVerifiedERC20At(0), address(verifiedERC20));
        assertTrue(verifiedERC20Factory.isVerifiedERC20(address(verifiedERC20)));

        address[] memory allVerifiedERC20s = verifiedERC20Factory.getAllVerifiedERC20s();
        assertEq(allVerifiedERC20s.length, 1);
        assertEq(allVerifiedERC20s[0], address(verifiedERC20));
    }
}
