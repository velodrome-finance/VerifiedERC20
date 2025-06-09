// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {ERC20Lockbox} from "src/external/ERC20Lockbox.sol";
import {SelfTransferHook} from "src/hooks/extensions/SelfTransferHook.sol";
import {SinglePermissionHook} from "src/hooks/extensions/SinglePermissionHook.sol";
import {TestSelfVerifiedERC20Deployment} from "test/mocks/TestSelfVerifiedERC20Deployment.sol";
import {DeploySelfVerifiedERC20} from "script/DeploySelfVerifiedERC20.s.sol";

import "test/BaseForkFixture.sol";

abstract contract BaseSelfForkFixture is BaseForkFixture {
    using stdStorage for StdStorage;

    // Contracts
    TestSelfVerifiedERC20Deployment public selfVerifiedERC20Deployment;
    ERC20Lockbox public lockbox;
    SinglePermissionHook public singlePermissionHook;
    SelfTransferHook public selfTransferHook;
    DeploySelfVerifiedERC20.SelfDeploymentParams internal _selfParams;

    function setUp() public override {
        vm.createSelectFork({urlOrAlias: "celo", blockNumber: 37593670});
        createUsers();

        deployContracts();
        labelContracts();
    }

    function deployContracts() internal override {
        super.deployContracts();

        _selfParams = DeploySelfVerifiedERC20.SelfDeploymentParams({
            verifiedERC20Name: "Self Verified ERC20 Celo",
            verifiedERC20Symbol: "VerifiedCelo",
            verifiedERC20Owner: users.owner,
            celo: CELO,
            singlePermissionHookName: "Single Permission Hook to restrict mints and burns to the lockbox",
            selfTransferHookName: "Self Transfer Hook to restrict incentive claims to verified users",
            verifiedERC20Factory: address(verifiedERC20Factory),
            outputFilename: ""
        });
        selfVerifiedERC20Deployment = new TestSelfVerifiedERC20Deployment({_params: _selfParams});
        selfVerifiedERC20Deployment.run();

        lockbox = selfVerifiedERC20Deployment.lockbox();
        singlePermissionHook = selfVerifiedERC20Deployment.singlePermissionHook();
        selfTransferHook = selfVerifiedERC20Deployment.selfTransferHook();
        verifiedERC20 = selfVerifiedERC20Deployment.verifiedERC20();
    }

    function labelContracts() internal override {
        super.labelContracts();

        vm.label({account: address(selfVerifiedERC20Deployment), newLabel: "SelfVerifiedERC20Deployment"});
        vm.label({account: address(singlePermissionHook), newLabel: "SinglePermissionHook"});
        vm.label({account: address(selfTransferHook), newLabel: "SelfTransferHook"});
    }
}
