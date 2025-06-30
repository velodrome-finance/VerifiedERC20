// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IERC20Lockbox} from "../interfaces/external/IERC20Lockbox.sol";
import {IVerifiedERC20} from "../interfaces/IVerifiedERC20.sol";

/// @title ERC20 Lockbox
/// @notice Lockbox to enable wrapping and unwrapping ERC20 into VerifiedERC20 tokens
/// @dev Adapted from XERC20Lockbox at https://github.com/velodrome-finance/superchain-contracts/blob/main/src/xerc20/XERC20Lockbox.sol
contract ERC20Lockbox is IERC20Lockbox {
    using SafeERC20 for IERC20;

    /// @inheritdoc IERC20Lockbox
    IVerifiedERC20 public immutable verifiedERC20;

    /// @inheritdoc IERC20Lockbox
    IERC20 public immutable ERC20;

    /// @notice Constructor
    /// @param _verifiedERC20 The address of the VerifiedERC20 contract
    /// @param _erc20 The address of the ERC20 contract
    constructor(address _verifiedERC20, address _erc20) {
        if (_verifiedERC20 == address(0) || _erc20 == address(0)) revert ERC20Lockbox_ZeroAddress();
        verifiedERC20 = IVerifiedERC20(_verifiedERC20);
        ERC20 = IERC20(_erc20);
    }

    /// @inheritdoc IERC20Lockbox
    function deposit(uint256 _amount) external {
        ERC20.safeTransferFrom({from: msg.sender, to: address(this), value: _amount});
        verifiedERC20.mint({_account: msg.sender, _value: _amount});
        emit Deposit({_sender: msg.sender, _amount: _amount});
    }

    /// @inheritdoc IERC20Lockbox
    function withdraw(uint256 _amount) external {
        verifiedERC20.burn({_account: msg.sender, _value: _amount});
        ERC20.safeTransfer({to: msg.sender, value: _amount});
        emit Withdraw({_sender: msg.sender, _receiver: msg.sender, _amount: _amount});
    }

    /// @inheritdoc IERC20Lockbox
    function withdrawTo(address _to, uint256 _amount) external {
        verifiedERC20.burn({_account: msg.sender, _value: _amount});
        ERC20.safeTransfer({to: _to, value: _amount});
        emit Withdraw({_sender: msg.sender, _receiver: _to, _amount: _amount});
    }
}
