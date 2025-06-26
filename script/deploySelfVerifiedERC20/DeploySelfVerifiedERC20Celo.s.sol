// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DeploySelfVerifiedERC20} from "../DeploySelfVerifiedERC20.s.sol";

import {MockIncentiveReward} from "test/mocks/MockIncentiveReward.sol";
import {MockSelfPassportSBT} from "test/mocks/MockSelfPassportSBT.sol";
import "forge-std/console.sol";

contract DeploySelfVerifiedERC20Celo is DeploySelfVerifiedERC20 {
    function setUp() public override {
        _params = DeploySelfVerifiedERC20.SelfDeploymentParams({
            verifiedERC20Name: "Self.xyz Verified ERC20 Celo",
            verifiedERC20Symbol: "vCelo",
            verifiedERC20Owner: 0xd42C7914cF8dc24a1075E29C283C581bd1b0d3D3, //TODO:
            celo: 0x471EcE3750Da237f93B8E339c536989b8978a438,
            singlePermissionMintHookName: "Single Permission Hook to restrict mints to the lockbox",
            singlePermissionBurnHookName: "Single Permission Hook to restrict burns to the lockbox",
            selfTransferHookName: "Hook to restrict incentive claims only to Self.xyz verified wallets",
            voter: 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123, //leaf voter on celo
            selfPassportSBT: 0xb8BEfA3900347057E57825BCEEbca1188209496c, //TODO:
            autoUnwrapHookName: "Hook for incentive claims to automatically unwrap to the base token",
            verifiedERC20Factory: 0x8a13CdB872B57091ae2B38b19f58fF9a7627df63, //TODO:
            outputFilename: "celo-self.json"
        });
    }
}
