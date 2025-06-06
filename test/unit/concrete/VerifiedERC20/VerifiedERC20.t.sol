// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseForkFixture.sol";

contract VerifiedERC20Test is BaseForkFixture {
    MockBooleanHook public beforeHook;
    MockBooleanHook public afterHook;

    function setUp() public virtual override {
        super.setUp();

        beforeHook = new MockBooleanHook();
        afterHook = new MockBooleanHook();

        vm.label(address(beforeHook), "beforeHook");
        vm.label(address(afterHook), "afterHook");
    }

    function test_InitialState() public view {
        assertEq(verifiedERC20.name(), "VerifiedERC20");
        assertEq(verifiedERC20.symbol(), "VerifiedERC20");
    }
}
