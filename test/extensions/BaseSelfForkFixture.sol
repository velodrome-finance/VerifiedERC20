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
    SinglePermissionHook public singlePermissionMintHook;
    SinglePermissionHook public singlePermissionBurnHook;
    SelfTransferHook public selfTransferHook;
    DeploySelfVerifiedERC20.SelfDeploymentParams internal _selfParams;

    function setUp() public override {
        vm.createSelectFork({urlOrAlias: "celo", blockNumber: 37593670});
        createUsers();

        deployContracts();

        postDeployment();
        labelContracts();
    }

    function deployContracts() internal override {
        super.deployContracts();

        _selfParams = DeploySelfVerifiedERC20.SelfDeploymentParams({
            verifiedERC20Name: "Self Verified ERC20 Celo",
            verifiedERC20Symbol: "VerifiedCelo",
            verifiedERC20Owner: users.owner,
            celo: CELO,
            singlePermissionMintHookName: "Single Permission Hook to restrict mints to the lockbox",
            singlePermissionBurnHookName: "Single Permission Hook to restrict burns to the lockbox",
            selfTransferHookName: "Self Transfer Hook to restrict incentive claims to users verified on self",
            verifiedERC20Factory: address(verifiedERC20Factory),
            outputFilename: ""
        });
        selfVerifiedERC20Deployment = new TestSelfVerifiedERC20Deployment({_selfParams: _selfParams});
        selfVerifiedERC20Deployment.run();

        lockbox = selfVerifiedERC20Deployment.lockbox();
        singlePermissionMintHook = selfVerifiedERC20Deployment.singlePermissionMintHook();
        singlePermissionBurnHook = selfVerifiedERC20Deployment.singlePermissionBurnHook();
        selfTransferHook = selfVerifiedERC20Deployment.selfTransferHook();
        verifiedERC20 = selfVerifiedERC20Deployment.verifiedERC20();
    }

    function postDeployment() internal {
        // Register hooks in hook registry
        vm.startPrank(users.owner);
        hookRegistry.registerHook({
            _hook: address(singlePermissionMintHook),
            _entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT
        });
        hookRegistry.registerHook({
            _hook: address(singlePermissionBurnHook),
            _entrypoint: IHookRegistry.Entrypoint.BEFORE_BURN
        });
        hookRegistry.registerHook({
            _hook: address(selfTransferHook),
            _entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER
        });
        vm.stopPrank();

        // Activate hooks in verified ERC20
        vm.startPrank(users.owner);
        verifiedERC20.activateHook({_hook: address(singlePermissionMintHook)});
        verifiedERC20.activateHook({_hook: address(singlePermissionBurnHook)});
        verifiedERC20.activateHook({_hook: address(selfTransferHook)});
    }

    function labelContracts() internal override {
        super.labelContracts();

        vm.label({account: address(selfVerifiedERC20Deployment), newLabel: "SelfVerifiedERC20Deployment"});
        vm.label({account: address(singlePermissionMintHook), newLabel: "SinglePermissionMintHook"});
        vm.label({account: address(singlePermissionBurnHook), newLabel: "SinglePermissionBurnHook"});
        vm.label({account: address(selfTransferHook), newLabel: "SelfTransferHook"});
    }
}
