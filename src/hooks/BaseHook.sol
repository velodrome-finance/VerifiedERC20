// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import {IHook} from "../interfaces/hooks/IHook.sol";
import {IMintHook} from "../interfaces/hooks/IMintHook.sol";
import {IBurnHook} from "../interfaces/hooks/IBurnHook.sol";
import {IApproveHook} from "../interfaces/hooks/IApproveHook.sol";

/**
 * @title BaseHook
 * @dev Abstract base contract for hooks that can be registered in a hook registry with mint, burn or approve as entrypoint
 *      Hook implementations need to override `supportsInterface(bytes4 interfaceId)` to specify the type of hook (IMintHook, IBurnHook or IApproveHook)
 */
abstract contract BaseHook is IHook, ERC165 {
    /// @inheritdoc IHook
    string public name;

    constructor(string memory _name) {
        name = _name;
    }

    /// @inheritdoc IHook
    function check(address _caller, bytes memory _params) external {
        (address _address, uint256 _amount) = _decodeParams({_params: _params});
        _check({_caller: _caller, _address: _address, _amount: _amount});
    }

    /**
     * @dev Internal function to be overriden
     * @param _caller The address of the caller
     * @param _address The address of the account being approved, minted, or burned
     * @param _amount The amount being approved, minted, or burned
     */
    function _check(address _caller, address _address, uint256 _amount) internal virtual;

    /**
     * @dev Helper function to decode parameters passed into check function
     * @param _params The abi encoded parameters
     * @return The decoded parameters
     */
    function _decodeParams(bytes memory _params) internal pure returns (address, uint256) {
        return abi.decode(_params, (address, uint256));
    }
}
