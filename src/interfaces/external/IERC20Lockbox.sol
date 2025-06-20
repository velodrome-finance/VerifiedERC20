// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IVerifiedERC20} from "../IVerifiedERC20.sol";

interface IERC20Lockbox {
    /**
     * @notice Error thrown when a zero address is provided
     */
    error ERC20Lockbox_ZeroAddress();

    /// @notice Emitted when tokens are deposited into the lockbox
    /// @param _sender The address of the user who deposited
    /// @param _amount The amount of tokens deposited
    event Deposit(address indexed _sender, uint256 _amount);

    /// @notice Emitted when tokens are withdrawn from the lockbox
    /// @param _sender The address of the user who withdrew
    /// @param _receiver The address of the user who receives the withdrawn tokens
    /// @param _amount The amount of tokens withdrawn
    event Withdraw(address indexed _sender, address indexed _receiver, uint256 _amount);

    /// @notice The VerifiedERC20 token of this contract
    function verifiedERC20() external view returns (IVerifiedERC20);

    /// @notice The ERC20 token of this contract
    function ERC20() external view returns (IERC20);

    /// @notice Deposit ERC20 tokens into the lockbox
    /// @param _amount The amount of tokens to deposit
    function deposit(uint256 _amount) external;

    /// @notice Withdraw ERC20 tokens from the lockbox
    /// @param _amount The amount of tokens to withdraw
    function withdraw(uint256 _amount) external;

    /// @notice Withdraw ERC20 tokens to a specific address
    /// @param _to The address to withdraw tokens to
    /// @param _amount The amount of tokens to withdraw
    function withdrawTo(address _to, uint256 _amount) external;
}
