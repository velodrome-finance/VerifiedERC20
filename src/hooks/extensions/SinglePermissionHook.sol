// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IHookRegistry} from "../../interfaces/hooks/IHookRegistry.sol";

import {BaseHook} from "../BaseHook.sol";

/**
 * @title SinglePermissionHook
 * @dev Hook to restrict mint and burn to an authorized address
 */
contract SinglePermissionHook is BaseHook {
    /// @notice Emitted when the _authorized address passed in constructor is zero
    error SinglePermissionHook_ZeroAddress();

    /// @notice Address of the authorized caller
    address public immutable authorized;

    constructor(string memory name, address _authorized) BaseHook(name) {
        if (_authorized == address(0)) revert SinglePermissionHook_ZeroAddress();
        authorized = _authorized;
    }

    function supportsEntrypoint(IHookRegistry.Entrypoint _entrypoint) external pure override returns (bool) {
        return
            _entrypoint == IHookRegistry.Entrypoint.BEFORE_MINT || _entrypoint == IHookRegistry.Entrypoint.BEFORE_BURN;
    }

    /**
     * @dev Restrict mint and burn to only allow the authorized address
     * @param _caller The address of the caller
     * @param _address The entity the tokens will be minted to or burned from
     * @param _amount The amount being transferred
     */
    function _check(address _caller, address _address, uint256 _amount) internal view override {
        if (_caller != authorized) {
            revert Hook_Revert({_params: abi.encode(_caller, _address, _amount)});
        }
    }
}
