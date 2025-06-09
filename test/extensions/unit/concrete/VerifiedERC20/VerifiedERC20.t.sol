// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseSelfForkFixture.sol";

contract VerifiedERC20Test is BaseSelfForkFixture {
    function test_InitialState() public view {
        assertEq(verifiedERC20.name(), "VerifiedERC20");
        assertEq(verifiedERC20.symbol(), "VerifiedERC20");
    }
}
