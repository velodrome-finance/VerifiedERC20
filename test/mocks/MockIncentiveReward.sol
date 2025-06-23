// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IReward} from "src/interfaces/external/IReward.sol";

contract MockIncentiveReward is IReward {
    address public voter = 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123;
    address public authorized = 0xF278761576f45472bdD721EACA19317cE159c011;

    function _deposit(uint256, uint256, uint256) external pure {
        revert("Not implemented");
    }

    function getReward(address, uint256, address[] memory) external pure {
        revert("Not implemented");
    }

    function notifyRewardAmount(address, uint256) external pure {
        revert("Not implemented");
    }
}
