// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IHookRegistry} from "./hooks/IHookRegistry.sol";

interface IVerifiedERC20 is IERC20 {
    /**
     * @notice Error thrown when a hook is not registered in the hook registry.
     * @param hook Address of the hook.
     */
    error VerifiedERC20_InvalidHook(address hook);

    /**
     * @notice Error thrown when trying to activate a hook that is already activated.
     * @param hook Address of the hook.
     */
    error VerifiedERC20_HookAlreadyActivated(address hook);

    /**
     * @notice Error thrown when trying to deactivate a hook that is not activated.
     * @param hook Address of the hook.
     */
    error VerifiedERC20_HookNotActivated(address hook);

    /**
     * @notice Error thrown when the maximum number of hooks for an entrypoint is exceeded.
     */
    error VerifiedERC20_MaxHooksExceeded();

    /**
     * @notice Error thrown when a hook reverts during execution.
     * @param data The data returned by the hook.
     */
    error VerifiedERC20_HookRevert(bytes data);

    /**
     * @notice Emitted when a hook is activated
     * @param hook Address of the activated hook
     * @param entrypoint The entrypoint of the activated hook
     */
    event HookActivated(address indexed hook, IHookRegistry.Entrypoint indexed entrypoint);

    /**
     * @notice Emitted when a hook is deactivated
     * @param hook Address of the deactivated hook
     * @param entrypoint The entrypoint of the deactivated hook
     */
    event HookDeactivated(address indexed hook, IHookRegistry.Entrypoint indexed entrypoint);

    /**
     * @dev Returns the maximum number of entrypoints
     * @return The maximum number of entrypoints
     */
    function MAX_ENTRYPOINTS() external pure returns (uint256);

    /**
     * @notice Returns the maximum number of hooks allowed per entrypoint
     * @return The maximum number of hooks per entrypoint
     */
    function MAX_HOOKS_PER_ENTRYPOINT() external view returns (uint256);

    /**
     * @notice Returns the maximum gas allowed per hook call
     * @return The maximum gas limit for each hook
     */
    function MAX_GAS_PER_HOOK() external view returns (uint256);

    /**
     * @notice The address of the hook registry contract
     * @return Address of the hook registry
     */
    function hookRegistry() external view returns (address);

    /**
     * @notice Activates a hook for the verifiedERC20 token
     * @param _hook Address of the hook to activate
     */
    function activateHook(address _hook) external;

    /**
     * @notice Deactivates a hook for the verifiedERC20 token
     * @param _hook Address of the hook to deactivate
     */
    function deactivateHook(address _hook) external;

    /**
     * @notice Maps hook addresses to their respective index in the entrypoint array
     * @param _hook The hook address to get the index for
     * @return The index of the hook in its entrypoint array
     * @dev Return index of 0 can mean either the first hook or that the hook is not registered. `isHookActivated` should be checked
     */
    function hookToIndex(address _hook) external view returns (uint256);

    /**
     * @notice Maps hook addresses to their respective entrypoint
     * @param _hook The hook address to get the entrypoint for
     * @return The entrypoint the hook is activated for
     * @dev Return entrypoint of 0 can mean either 'BEFORE_APPROVE` or that the hook is not registered. `isHookActivated` should be checked
     */
    function hookToEntrypoint(address _hook) external view returns (IHookRegistry.Entrypoint);

    /**
     * @notice Maps hook addresses to their activation status
     * @param _hook The hook address to check activation status for
     * @return Whether the hook is currently activated
     */
    function isHookActivated(address _hook) external view returns (bool);

    /**
     * @notice Gets all hooks for a specific entrypoint
     * @param _entrypoint The entrypoint to get hooks for
     * @return Array of hook addresses for the entrypoint
     */
    function getHooksForEntrypoint(IHookRegistry.Entrypoint _entrypoint) external view returns (address[] memory);

    /**
     * @notice Gets a hook at a specific index for an entrypoint
     * @param _entrypoint The entrypoint to get the hook from
     * @param _index The index of the hook to get
     * @return The hook address at the specified index
     */
    function getHookAtIndex(IHookRegistry.Entrypoint _entrypoint, uint256 _index) external view returns (address);

    /**
     * @notice Gets the number of hooks for a specific entrypoint
     * @param _entrypoint The entrypoint to get the count for
     * @return The number of hooks for the entrypoint
     */
    function getHooksCountForEntrypoint(IHookRegistry.Entrypoint _entrypoint) external view returns (uint256);

    /**
     * @notice Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * @param _account The address to which the tokens will be minted
     * @param _value The amount of tokens to mint
     */
    function mint(address _account, uint256 _value) external;

    /**
     * @notice Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * @param _account The address from which the tokens will be burned
     * @param _value The amount of tokens to burn
     */
    function burn(address _account, uint256 _value) external;
}
