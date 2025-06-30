// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHookRegistry} from "./IHookRegistry.sol";

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
     * @notice Checks if the hook supports a specific entrypoint
     * @param _entrypoint The entrypoint to check support for
     * @return True if the hook supports the entrypoint, false otherwise
     */
    function supportsEntrypoint(IHookRegistry.Entrypoint _entrypoint) external view returns (bool);

    /**
     * @notice Calls the hook to check the function is allowed to be executed
     * @param _caller The caller of the VerifiedERC20 function
     * @param _params The function VerifiedERC20 function params encoded
     */
    function check(address _caller, bytes memory _params) external;
}
