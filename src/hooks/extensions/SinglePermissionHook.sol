// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IMintHook} from "../../interfaces/hooks/IMintHook.sol";
import {IBurnHook} from "../../interfaces/hooks/IBurnHook.sol";

import {BaseAHook} from "../BaseAHook.sol";

/**
 * @title SinglePermissionHook
 * @dev Hook to restrict mint and burn to an authorized address
 */
contract SinglePermissionHook is BaseAHook {
    /// @notice Emitted when the _authorized address passed in constructor is zero
    error SinglePermissionHook_ZeroAddress();

    address public authorized;

    constructor(address _authorized) {
        if (_authorized == address(0)) revert SinglePermissionHook_ZeroAddress();
        authorized = _authorized;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IMintHook).interfaceId || interfaceId == type(IBurnHook).interfaceId;
    }

    /**
     * @dev Restrict mint and burn to only allow the authorized address
     * @param _caller The address of the caller
     * @param _address The entity the tokens will be minted to or burned from
     * @param _amount The amount being transferred
     */
    function _check(address _caller, address _address, uint256 _amount) internal override {
        if (_caller != authorized) {
            revert Hook_Revert({_params: abi.encode(_caller, _address, _amount)});
        }
    }
}
