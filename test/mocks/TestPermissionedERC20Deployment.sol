// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../script/DeployPermissionedERC20.s.sol";

contract TestPermissionedERC20Deployment is DeployPermissionedERC20 {
    constructor(string memory _name, string memory _symbol, string memory _outputFilename) {
        _params = PermissionedERC20DeploymentParams({name: _name, symbol: _symbol, outputFilename: _outputFilename});
        isTest = true;
    }
}
