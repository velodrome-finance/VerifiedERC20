// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseForkFixture.sol";

contract VerifiedERC20Test is BaseForkFixture {
    IHook public beforeHook;
    IHook public afterHook;

    function setUp() public virtual override {
        super.setUp();
        _deployHooks();
    }

    function _deployHooks() internal virtual {
        beforeHook = new MockSuccessHook();
        afterHook = new MockSuccessHook();

        vm.label(address(beforeHook), "beforeHook");
        vm.label(address(afterHook), "afterHook");
    }

    function test_InitialState() public view {
        assertEq(verifiedERC20.name(), "VerifiedERC20");
        assertEq(verifiedERC20.symbol(), "VerifiedERC20");
        assertEq(verifiedERC20.MAX_ENTRYPOINTS(), uint256(type(IHookRegistry.Entrypoint).max) + 1);
    }
}
