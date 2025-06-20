// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReward {
    /// @notice Epoch duration constant (7 days)
    function DURATION() external view returns (uint256);

    /// @notice Address of LeafVoter.sol
    function voter() external view returns (address);

    /// @notice Deposit an amount into the rewards contract to earn future rewards associated to a veNFT
    /// @dev Internal notation used as only callable internally by `authorized.module()`.
    /// @param amount Vote weight to deposit
    /// @param tokenId Token ID of weight to deposit
    /// @param timestamp Timestamp of deposit
    function _deposit(uint256 amount, uint256 tokenId, uint256 timestamp) external;

    /// @notice Claim the rewards earned by a veNFT staker
    /// @param _recipient  Address of reward recipient
    /// @param _tokenId  Unique identifier of the veNFT
    /// @param _tokens   Array of tokens to claim rewards of
    function getReward(address _recipient, uint256 _tokenId, address[] memory _tokens) external;

    /// @notice Add rewards for stakers to earn
    /// @param token    Address of token to reward
    /// @param amount   Amount of token to transfer to rewards
    function notifyRewardAmount(address token, uint256 amount) external;
}
