// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../AutoUnwrapHook.t.sol";

contract CheckConcreteTest is AutoUnwrapHookTest {
    function setUp() public override {
        super.setUp();

        /// @dev Simulate incentive claim to alice. AutoUnwrapHook is a post transfer hook
        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: address(users.alice), _value: MAX_TOKENS});

        // @dev Give tokens to lockbox to unwrap
        deal({token: CELO, to: address(lockbox), give: MAX_TOKENS});
    }

    function test_WhenTheFromAddressIsNotAnIncentiveContract() external {
        // It should do nothing and not revert
        address _caller = users.alice;
        address _from = users.bob;
        address _to = users.alice;
        uint256 _amount = 1000;

        bytes memory params = abi.encode(_from, _to, _amount);

        autoUnwrapHook.check(_caller, params);
    }

    modifier whenTheFromAddressIsAnIncentiveContract() {
        _;
    }

    function test_WhenTheToPassedHasntApprovedTheHook() external whenTheFromAddressIsAnIncentiveContract {
        // It should revert with {ERC20InsufficientAllowance}
        address _caller = users.alice;
        address _from = address(incentiveReward);
        address _to = users.alice;
        uint256 _amount = MAX_TOKENS;

        bytes memory params = abi.encode(_from, _to, _amount);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector, address(autoUnwrapHook), 0, _amount
            )
        );

        vm.prank(address(verifiedERC20));
        autoUnwrapHook.check(_caller, params);
    }

    function test_WhenTheToPassedApprovedTheHook() external whenTheFromAddressIsAnIncentiveContract {
        // It should unwrap the verifiedERC20 to its base ERC20
        address _caller = users.alice;
        address _from = address(incentiveReward);
        address _to = users.alice;
        uint256 _amount = MAX_TOKENS;
        vm.prank(_to);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: MAX_TOKENS});

        bytes memory params = abi.encode(_from, _to, _amount);
        vm.prank(address(verifiedERC20));
        autoUnwrapHook.check(_caller, params);
        assertEq(IERC20(CELO).balanceOf(_to), MAX_TOKENS);
        assertEq(verifiedERC20.balanceOf(_to), 0);
        assertEq(verifiedERC20.balanceOf(address(autoUnwrapHook)), 0);
        assertEq(verifiedERC20.balanceOf(address(incentiveReward)), 0);
    }

    function testGas_check() external whenTheFromAddressIsAnIncentiveContract {
        // It should unwrap the verifiedERC20 to its base ERC20
        address _caller = users.alice;
        address _from = address(incentiveReward);
        address _to = users.alice;
        uint256 _amount = MAX_TOKENS;
        vm.prank(_to);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: MAX_TOKENS});

        bytes memory params = abi.encode(_from, _to, _amount);
        vm.prank(address(verifiedERC20));
        autoUnwrapHook.check(_caller, params);
        vm.snapshotGasLastCall({name: "AutoUnwrapHook_check"});
    }
}
