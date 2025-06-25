// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DeployVerifiedERC20} from "../DeployVerifiedERC20.s.sol";

contract DeployVerifiedERC20Celo is DeployVerifiedERC20 {
    function setUp() public override {
        _params = DeployVerifiedERC20.DeploymentParams({
            hookRegistryManager: 0xd42C7914cF8dc24a1075E29C283C581bd1b0d3D3,
            outputFilename: "celo.json"
        });
    }
}
