// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReward {
    /// @notice Epoch duration constant (7 days)
    function DURATION() external view returns (uint256);

    /// @notice Address of LeafVoter.sol
    function voter() external view returns (address);
}
