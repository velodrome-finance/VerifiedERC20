// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DeploySelfVerifiedERC20} from "../DeploySelfVerifiedERC20.s.sol";

contract DeploySelfVerifiedERC20Celo is DeploySelfVerifiedERC20 {
    function setUp() public override {
        _params = DeploySelfVerifiedERC20.SelfDeploymentParams({
            verifiedERC20Name: "Self.xyz Verified ERC20 Celo",
            verifiedERC20Symbol: "vCELO",
            verifiedERC20Owner: address(0), //TODO:
            celo: 0x471EcE3750Da237f93B8E339c536989b8978a438,
            singlePermissionMintHookName: "Single Permission Hook to restrict mints to the lockbox",
            singlePermissionBurnHookName: "Single Permission Hook to restrict burns to the lockbox",
            selfTransferHookName: "Hook to restrict incentive claims only to Self.xyz verified wallets",
            voter: 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123, //leaf voter on celo
            selfPassportSBT: address(0), //TODO:
            autoUnwrapHookName: "Hook for incentive claims to automatically unwrap to the base token",
            verifiedERC20Factory: 0x270176c42dAaFF1CEb6369601Ebe1d2e9Bb9218F,
            outputFilename: "celo-self.json"
        });
    }
}
