// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {IReward} from "src/interfaces/external/IReward.sol";

contract MockIncentiveReward is IReward {
    uint256 public constant DURATION = 7 days;
    address public voter = 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123;

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
