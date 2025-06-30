// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../SelfTransferHook.t.sol";

contract CheckConcreteTest is SelfTransferHookTest {
    function test_WhenTheFromAddressIsNotAnIncentiveContract() external {
        // It should do nothing and not revert
        address _caller = users.alice;
        address _from = users.bob;
        address _to = users.alice;
        uint256 _amount = 1000;

        bytes memory params = abi.encode(_from, _to, _amount);

        selfTransferHook.check(_caller, params);
    }

    modifier whenTheFromAddressIsAnIncentiveContract() {
        _;
    }

    function test_WhenTheToPassedIsNotVerified() external whenTheFromAddressIsAnIncentiveContract {
        // It should revert with {Hook_Revert}
        address _caller = users.alice;
        address _from = address(incentiveReward);
        address _to = users.alice;
        uint256 _amount = MAX_TOKENS;

        bytes memory params = abi.encode(_from, _to, _amount);

        vm.expectRevert(abi.encodeWithSelector(IHook.Hook_Revert.selector, abi.encode(_caller, _from, _to, _amount)));
        selfTransferHook.check(_caller, params);
    }

    function test_WhenTheToPassedIsVerified() external whenTheFromAddressIsAnIncentiveContract {
        // It should do nothing and not revert
        address _caller = users.alice;
        address _from = address(incentiveReward);
        address _to = users.alice;
        uint256 _amount = MAX_TOKENS;

        selfPassportSBT.mint({to: users.alice, tokenId: 1});

        bytes memory params = abi.encode(_from, _to, _amount);

        selfTransferHook.check(_caller, params);
    }

    function testGas_check() external whenTheFromAddressIsAnIncentiveContract {
        // It should do nothing and not revert
        address _caller = users.alice;
        address _from = address(incentiveReward);
        address _to = users.alice;
        uint256 _amount = MAX_TOKENS;

        selfPassportSBT.mint({to: users.alice, tokenId: 1});

        bytes memory params = abi.encode(_from, _to, _amount);

        selfTransferHook.check(_caller, params);
        vm.snapshotGasLastCall({name: "SelfTransferHook_check"});
    }
}
