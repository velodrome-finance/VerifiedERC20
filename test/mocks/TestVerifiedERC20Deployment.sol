// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "../../script/DeployVerifiedERC20.s.sol";

contract TestVerifiedERC20Deployment is DeployVerifiedERC20 {
    constructor(address _hookRegistryManager, string memory _outputFilename) {
        _params = DeploymentParams({hookRegistryManager: _hookRegistryManager, outputFilename: _outputFilename});
        isTest = true;
    }
}
