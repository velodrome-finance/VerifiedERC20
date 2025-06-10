// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../script/DeploySelfVerifiedERC20.s.sol";

contract TestSelfVerifiedERC20Deployment is DeploySelfVerifiedERC20 {
    constructor(DeploySelfVerifiedERC20.SelfDeploymentParams memory _params) {
        _params = _params;
        isTest = true;
    }
}
