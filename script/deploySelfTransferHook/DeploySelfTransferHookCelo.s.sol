// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DeploySelfTransferHook} from "../DeploySelfTransferHook.s.sol";

contract DeploySelfTransferHookCelo is DeploySelfTransferHook {
    function setUp() public override {
        _params = DeploySelfTransferHook.SelfTransferHookDeploymentParams({
            selfTransferHookName: "Hook to restrict incentive claims only to Self.xyz verified wallets",
            voter: 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123, //leaf voter on celo
            selfPassportSBT: 0xB69F2308f62f4E4b457Cad4722DA5ab0EA57B97a,
            outputFilename: "celo-self.json"
        });
    }
}
