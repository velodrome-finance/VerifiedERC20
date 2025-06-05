// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import {IHook} from "../interfaces/hooks/IHook.sol";
import {ITransferHook} from "../interfaces/hooks/ITransferHook.sol";

/**
 * @title BaseBHook
 * @dev Abstract base contract for hooks that can be registered in a hook registry with transfer as entrypoint
 */
abstract contract BaseBHook is IHook, ERC165 {
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ITransferHook).interfaceId || super.supportsInterface(interfaceId);
    }

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
