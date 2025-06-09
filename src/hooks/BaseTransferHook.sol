// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IHook, IHookRegistry} from "../interfaces/hooks/IHook.sol";

/**
 * @title BaseTransferHook
 * @dev Abstract base contract for hooks that can be registered in a hook registry with transfer as entrypoint
 *      Hook implementations need to override `supportsEntrypoint` to specify the type of entrypoint (BEFORE_TRANSFER or AFTER_TRANSFER)
 */
abstract contract BaseTransferHook is IHook {
    /// @inheritdoc IHook
    string public name;

    constructor(string memory _name) {
        name = _name;
    }

    /// @inheritdoc IHook
    function supportsEntrypoint(IHookRegistry.Entrypoint _entrypoint) external view virtual returns (bool);

    /// @inheritdoc IHook
    function check(address _caller, bytes memory _params) external {
        (address _from, address _to, uint256 _amount) = _decodeParams({_params: _params});
        _check({_caller: _caller, _from: _from, _to: _to, _amount: _amount});
    }

    /**
     * @dev Internal function to be overriden
     * @param _caller The address of the caller
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _amount The amount being transferred
     */
    function _check(address _caller, address _from, address _to, uint256 _amount) internal virtual;

    /**
     * @dev Helper function to decode parameters passed into check function
     * @param _params The abi encoded parameters
     * @return The decoded transfer parameters
     */
    function _decodeParams(bytes memory _params) internal pure returns (address, address, uint256) {
        return abi.decode(_params, (address, address, uint256));
    }
}
