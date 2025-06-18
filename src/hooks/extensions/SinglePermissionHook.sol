// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IHookRegistry} from "../../interfaces/hooks/IHookRegistry.sol";
import {IVerifiedERC20} from "../../interfaces/IVerifiedERC20.sol";

import {BaseHook} from "../BaseHook.sol";

/**
 * @title SinglePermissionHook
 * @dev Hook to restrict mint and burn to an authorized address
 */
contract SinglePermissionHook is BaseHook {
    /// @notice Emitted when the _authorized address passed in constructor is zero
    error SinglePermissionHook_ZeroAddress();

    /// @notice Emitted when the caller is not authorized
    error SinglePermissionHook_NotAuthorized(address _caller, address _verifiedERC20, address _authorized);

    /// @notice Emitted when the authorized mapping is set
    event AuthorizedSet(address indexed verifiedERC20, address indexed authorized);

    /// @notice Address of the authorized caller
    mapping(address _verifiedERC20 => address _authorized) public authorized;

    /**
     * @notice Constructor to initialize the hook with a name and initial authorized addresses
     * @param _name The name of the hook
     * @param _verifiedERC20s The addresses of the verified ERC20 tokens this hook will be associated with initially
     * @param _authorized The addresses of the authorized callers for each initial verified ERC20
     * @dev The initial mapping settings are unrestricted to verifiedERC20.owner since the hook will need to be registered in the
     *        HookRegistry to become available and this is done by a trusted entity who will verify the mapping is not incorrectly set.
     */
    constructor(string memory _name, address[] memory _verifiedERC20s, address[] memory _authorized) BaseHook(_name) {
        for (uint256 i = 0; i < _verifiedERC20s.length;) {
            if (_authorized[i] == address(0) || _verifiedERC20s[i] == address(0)) {
                revert SinglePermissionHook_ZeroAddress();
            }
            _setAuthorized({_verifiedERC20: _verifiedERC20s[i], _authorized: _authorized[i]});
            unchecked {
                i++;
            }
        }
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
        if (_caller != authorized[msg.sender]) {
            revert Hook_Revert({_params: abi.encode(_caller, _address, _amount)});
        }
    }

    /**
     * @notice Set authorized address for the verifiedERC20
     * @param _verifiedERC20 address of the verifiedERC20 to set the authorized caller
     * @param _authorized address of the authorized caller
     * @dev This hook doesn't allow to set address(0) as authorized. To block mints/burns, a different hook should be used instead.
     */
    function setAuthorized(address _verifiedERC20, address _authorized) external {
        if (_authorized == address(0) || _verifiedERC20 == address(0)) {
            revert SinglePermissionHook_ZeroAddress();
        }
        if (msg.sender != Ownable(_verifiedERC20).owner()) {
            revert SinglePermissionHook_NotAuthorized({
                _caller: msg.sender,
                _verifiedERC20: _verifiedERC20,
                _authorized: _authorized
            });
        }
        _setAuthorized({_verifiedERC20: _verifiedERC20, _authorized: _authorized});
    }

    function _setAuthorized(address _verifiedERC20, address _authorized) internal {
        authorized[_verifiedERC20] = _authorized;

        emit AuthorizedSet({verifiedERC20: _verifiedERC20, authorized: _authorized});
    }
}
