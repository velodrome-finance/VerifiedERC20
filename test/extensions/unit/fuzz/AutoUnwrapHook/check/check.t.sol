// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../AutoUnwrapHook.t.sol";

contract CheckFuzzTest is AutoUnwrapHookTest {
    function setUp() public override {
        super.setUp();

        // @dev Give tokens to lockbox to unwrap
        deal({token: CELO, to: address(lockbox), give: MAX_TOKENS});
    }

    function testFuzz_WhenTheFromAddressIsNotAnIncentiveContract(address _from, uint256 _amount) external {
        // It should do nothing and not revert
        vm.assume(_from != address(incentiveReward));
        address _caller = users.alice;
        address _to = users.alice;

        bytes memory params = abi.encode(_from, _to, _amount);

        autoUnwrapHook.check(_caller, params);
    }

    modifier whenTheFromAddressIsAnIncentiveContract() {
        _;
    }

    function testFuzz_WhenTheToPassedHasntApprovedTheHook(address _to, uint256 _amount)
        external
        whenTheFromAddressIsAnIncentiveContract
    {
        // It should revert with {ERC20InsufficientAllowance}
        vm.assume(_to != address(0));
        address _caller = users.alice;
        address _from = address(incentiveReward);
        _amount = bound(_amount, 1, MAX_TOKENS);
        uint256 _allowance = bound(_amount, 0, _amount - 1);
        vm.prank(_to);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: _allowance});

        bytes memory params = abi.encode(_from, _to, _amount);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector, address(autoUnwrapHook), _allowance, _amount
            )
        );

        vm.prank(address(verifiedERC20));
        autoUnwrapHook.check(_caller, params);
    }

    function testFuzz_WhenTheToPassedApprovedTheHook(address _to, uint256 _amount)
        external
        whenTheFromAddressIsAnIncentiveContract
    {
        // It should unwrap the verifiedERC20 to its base ERC20

        // _to == incentiveReward breaks the tests since it triggers the _isClaimIncentive on VerifiedERC20.transferFrom(_to, address(this)).
        // We can safely remove this tests case since the incentive reward does not claim to itself
        vm.assume(_to != address(0) && _to != address(incentiveReward));
        uint256 balanceBefore = IERC20(CELO).balanceOf(_to);
        address _caller = users.alice;
        address _from = address(incentiveReward);
        _amount = bound(_amount, 1, MAX_TOKENS);
        vm.prank(_to);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: MAX_TOKENS});

        /// @dev Simulate incentive claim. AutoUnwrapHook is a post transfer hook
        vm.prank(address(lockbox));
        verifiedERC20.mint({_account: _to, _value: _amount});

        bytes memory params = abi.encode(_from, _to, _amount);
        vm.prank(address(verifiedERC20));
        autoUnwrapHook.check(_caller, params);
        assertEq(IERC20(CELO).balanceOf(_to), balanceBefore + _amount);
        assertEq(verifiedERC20.balanceOf(_to), 0);
        assertEq(verifiedERC20.balanceOf(address(autoUnwrapHook)), 0);
        assertEq(verifiedERC20.balanceOf(address(incentiveReward)), 0);
    }
}
