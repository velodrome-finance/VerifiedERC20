// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DeployVerifiedERC20} from "../DeployVerifiedERC20.s.sol";

contract DeployVerifiedERC20Celo is DeployVerifiedERC20 {
    function setUp() public override {
        _params = DeployVerifiedERC20.DeploymentParams({
            hookRegistryManager: 0x9d5064e4910410f56626d2D187758d83D8e85860,
            outputFilename: "celo.json"
        });
    }
}
