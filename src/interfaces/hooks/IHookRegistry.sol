// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

interface IHookRegistry {
    /**
     * @dev Enum defining the entrypoints where hooks can be triggered
     */
    enum Entrypoint {
        BEFORE_APPROVE,//0
        AFTER_APPROVE,//1
        BEFORE_TRANSFER,//2
        AFTER_TRANSFER,//3
        BEFORE_MINT,//4
        AFTER_MINT,//5
        BEFORE_BURN,//6
        AFTER_BURN//7
    }

    /**
     * @dev Emitted when a hook is registered
     * @param hook Address of the registered hook
     * @param entrypoint The entrypoint assigned to the hook
     */
    event HookRegistered(address indexed hook, Entrypoint indexed entrypoint);

    /**
     * @dev Emitted when a hook is deregistered
     * @param hook Address of the deregistered hook
     */
    event HookDeregistered(address indexed hook);

    /**
     * @dev Error thrown when a zero address is provided
     */
    error HookRegistry_ZeroAddress();

    /**
     * @dev Error thrown when trying to register a hook that is already registered
     */
    error HookRegistry_HookAlreadyRegistered();

    /**
     * @dev Error thrown when trying to deregister a hook that is not registered
     */
    error HookRegistry_HookNotRegistered();

    /**
     * @dev Error thrown when an invalid entrypoint is provided
     */
    error HookRegistry_HookDoesNotSupportEntrypoint(Entrypoint entrypoint);

    /**
     * @dev Registers a hook with the specified entrypoint
     * @param _hook Address of the hook to register
     * @param _entrypoint The entrypoint to assign to the hook
     */
    function registerHook(address _hook, Entrypoint _entrypoint) external;

    /**
     * @dev Deregisters a hook
     * @param _hook Address of the hook to deregister
     */
    function deregisterHook(address _hook) external;

    /**
     * @dev Returns the entrypoint associated with a hook
     * @param _hook The hook address to query
     * @return The entrypoint assigned to the hook
     * @dev Return entrypoint of 0 can mean either 'BEFORE_APPROVE` or that the hook is not registered. `isHookRegistered` should be checked
     */
    function hookEntrypoints(address _hook) external view returns (Entrypoint);

    /**
     * @dev Returns the total number of registered hooks
     * @return The count of registered hooks
     */
    function getHookCount() external view returns (uint256);

    /**
     * @dev Returns the hook address at a given index
     * @param _index The index of the hook to retrieve
     * @return The address of the hook at the specified index
     */
    function getHookAt(uint256 _index) external view returns (address);

    /**
     * @dev Checks if a hook is registered
     * @param _hook The hook address to check
     * @return True if the hook is registered, false otherwise
     */
    function isHookRegistered(address _hook) external view returns (bool);

    /**
     * @dev Returns all registered hooks
     * @return An array of all registered hook addresses
     */
    function getAllHooks() external view returns (address[] memory);
}
