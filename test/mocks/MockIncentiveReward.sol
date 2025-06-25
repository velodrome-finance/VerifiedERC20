// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IReward} from "src/interfaces/external/IReward.sol";

contract MockIncentiveReward is IReward {
    using SafeERC20 for IERC20;

    address public voter = 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123;
    address public authorized = 0xF278761576f45472bdD721EACA19317cE159c011;

    function _deposit(uint256 amount, uint256 tokenId, uint256 timestamp) external {
        revert("Not implemented");
    }

    function getReward(address _recipient, uint256 _tokenId, address[] memory _tokens) external {
        _getReward({_recipient: _recipient, _tokenId: _tokenId, _tokens: _tokens});
    }

    function notifyRewardAmount(address token, uint256 amount) external {
        _notifyRewardAmount(msg.sender, token, amount);
    }

    function earned(address token, uint256 tokenId) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function _getReward(address _recipient, uint256 _tokenId, address[] memory _tokens) internal {
        uint256 _length = _tokens.length;
        for (uint256 i = 0; i < _length; i++) {
            uint256 _reward = earned(_tokens[i], _tokenId);
            if (_reward > 0) IERC20(_tokens[i]).safeTransfer(_recipient, _reward);
        }
    }

    function _notifyRewardAmount(address sender, address token, uint256 amount) internal {
        if (amount == 0) revert("ZeroAmount");
        IERC20(token).safeTransferFrom(sender, address(this), amount);
    }
}
