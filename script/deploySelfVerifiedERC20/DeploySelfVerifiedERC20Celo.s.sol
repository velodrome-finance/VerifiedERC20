// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DeploySelfVerifiedERC20} from "../DeploySelfVerifiedERC20.s.sol";

import {MockIncentiveReward} from "test/mocks/MockIncentiveReward.sol";
import {MockSelfPassportSBT} from "test/mocks/MockSelfPassportSBT.sol";
import "forge-std/console.sol";

contract DeploySelfVerifiedERC20Celo is DeploySelfVerifiedERC20 {
    function setUp() public override {
        _params = DeploySelfVerifiedERC20.SelfDeploymentParams({
            verifiedERC20Name: "Self Verified ERC20 Celo",
            verifiedERC20Symbol: "VerifiedCelo",
            verifiedERC20Owner: 0xd42C7914cF8dc24a1075E29C283C581bd1b0d3D3, //TODO:
            celo: 0x471EcE3750Da237f93B8E339c536989b8978a438,
            singlePermissionMintHookName: "Single Permission Hook to restrict mints to the lockbox",
            singlePermissionBurnHookName: "Single Permission Hook to restrict burns to the lockbox",
            selfTransferHookName: "Self Transfer Hook to restrict incentive claims to users verified on self",
            voter: 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123, //leaf voter on celo
            selfPassportSBT: address(0), //TODO:
            autoUnwrapHookName: "Auto Unwrap Hook to automatically unwrap verified erc20 to the base token on claim incentive",
            verifiedERC20Factory: address(0), //TODO:
            outputFilename: "celo-self.json"
        });
    }

    /// @dev Overriding for test purposes. Will revert change later
    function deploy() internal override {
        MockSelfPassportSBT mockSelfPassportSBT = new MockSelfPassportSBT();
        _params.selfPassportSBT = address(mockSelfPassportSBT);

        super.deploy();

        MockIncentiveReward mockIncentiveReward = new MockIncentiveReward();

        console.log("mockInceitveReward: ", address(mockIncentiveReward));
        console.log("mockSelfPassportSBT: ", address(mockSelfPassportSBT));

        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/deployment-addresses/", _params.outputFilename));
        vm.writeJson(vm.toString(address(mockIncentiveReward)), path, ".MockIncentiveReward");
        vm.writeJson(vm.toString(address(mockSelfPassportSBT)), path, ".MockSelfPassportSBT");
    }
}
