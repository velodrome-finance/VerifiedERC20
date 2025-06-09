// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IHook
 * @notice Interface for hook functionality
 */
interface IHook {
    /**
     * @notice Error thrown when the hook reverts
     */
    error Hook_Revert(bytes _params);

    /**
     * @notice Returns the hook name
     * @return The hook name as a string
     */
    function name() external view returns (string memory);

    /**
     * @notice Calls the hook to check the function is allowed to be executed
     * @param _caller The caller of the VerifiedERC20 function
     * @param _params The function VerifiedERC20 function params encoded
     */
    function check(address _caller, bytes memory _params) external;
}
