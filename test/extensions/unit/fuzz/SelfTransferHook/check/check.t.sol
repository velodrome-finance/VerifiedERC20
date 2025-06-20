// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../SelfTransferHook.t.sol";

contract CheckConcreteTest is SelfTransferHookTest {
    function test_WhenTheFromAddressIsNotAnIncentiveContract(address _from) external {
        // It should do nothing and not revert
        vm.assume(_from != address(incentiveReward));
        address _caller = users.alice;
        address _to = users.alice;
        uint256 _amount = 1000;

        bytes memory params = abi.encode(_from, _to, _amount);

        selfTransferHook.check(_caller, params);
    }

    modifier whenTheFromAddressIsAnIncentiveContract() {
        _;
    }

    function test_WhenTheToPassedIsNotVerified(address _to) external whenTheFromAddressIsAnIncentiveContract {
        // It should revert with {Hook_Revert}
        vm.assume(_to != address(0));
        address _caller = users.alice;
        address _from = address(incentiveReward);
        uint256 _amount = MAX_TOKENS;

        bytes memory params = abi.encode(_from, _to, _amount);

        vm.expectRevert(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _from, _to, _amount)));
        selfTransferHook.check(_caller, params);
    }

    function test_WhenTheToPassedIsVerified(address _to, uint256 _amount)
        external
        whenTheFromAddressIsAnIncentiveContract
    {
        // It should do nothing and not revert
        vm.assume(_to != address(0));
        address _caller = users.alice;
        address _from = address(incentiveReward);

        selfPassportSBT.mint({to: _to, tokenId: 1});

        bytes memory params = abi.encode(_from, _to, _amount);

        selfTransferHook.check(_caller, params);
    }
}
