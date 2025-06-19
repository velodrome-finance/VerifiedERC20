// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {IHookRegistry} from "../interfaces/hooks/IHookRegistry.sol";
import {IHook} from "../interfaces/hooks/IHook.sol";

/**
 * @title HookRegistry
 * @dev Registry for hooks that can be triggered at different entrypoints
 */
contract HookRegistry is IHookRegistry, Ownable, ReentrancyGuardTransient {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @inheritdoc IHookRegistry
    uint256 public constant MAX_ENTRYPOINTS = 8;

    // Set of registered hooks
    EnumerableSet.AddressSet private _hooks;

    /// @inheritdoc IHookRegistry
    mapping(address _hook => Entrypoint _entrypoint) public hookEntrypoints;

    constructor(address owner_) Ownable(owner_) {}

    /// @inheritdoc IHookRegistry
    function registerHook(address _hook, Entrypoint _entrypoint) external onlyOwner nonReentrant {
        if (_hook == address(0)) revert HookRegistry_ZeroAddress();
        if (!_hooks.add({value: _hook})) revert HookRegistry_HookAlreadyRegistered();

        if (!IHook(_hook).supportsEntrypoint({_entrypoint: _entrypoint})) {
            revert HookRegistry_HookDoesNotSupportEntrypoint({entrypoint: _entrypoint});
        }

        hookEntrypoints[_hook] = _entrypoint;

        emit HookRegistered({hook: _hook, entrypoint: _entrypoint});
    }

    /// @inheritdoc IHookRegistry
    function deregisterHook(address _hook) external onlyOwner nonReentrant {
        if (!_hooks.remove({value: _hook})) revert HookRegistry_HookNotRegistered();

        // Clear the hook's entrypoint mapping
        delete hookEntrypoints[_hook];

        emit HookDeregistered({hook: _hook});
    }

    /// @inheritdoc IHookRegistry
    function getHookCount() external view returns (uint256) {
        return _hooks.length();
    }

    /// @inheritdoc IHookRegistry
    function getHookAt(uint256 _index) external view returns (address) {
        return _hooks.at({index: _index});
    }

    /// @inheritdoc IHookRegistry
    function isHookRegistered(address _hook) external view returns (bool) {
        return _hooks.contains({value: _hook});
    }

    /// @inheritdoc IHookRegistry
    function getAllHooks() external view returns (address[] memory) {
        return _hooks.values();
    }
}
