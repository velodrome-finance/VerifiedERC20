// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IHookRegistry} from "../../interfaces/hooks/IHookRegistry.sol";

import {BaseTransferHook} from "../BaseTransferHook.sol";

/**
 * @title SelfTransferHook
 * @dev Hook to restrict incentive claims to users verified on Self
 */
contract SelfTransferHook is BaseTransferHook {
    constructor(string memory name) BaseTransferHook(name) {}

    function supportsEntrypoint(IHookRegistry.Entrypoint _entrypoint) external pure override returns (bool) {
        return _entrypoint == IHookRegistry.Entrypoint.BEFORE_TRANSFER;
    }
    /**
     * @dev Restrict transfers to only allow verified users to claim incentives
     * @param _caller The address of the caller
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _amount The amount being transferred
     */

    function _check(address _caller, address _from, address _to, uint256 _amount) internal override {
        if (_isClaimIncentive() && !_isVerified({_user: _to})) {
            revert Hook_Revert({_params: abi.encode(_caller, _from, _to, _amount)});
        }
    }

    /**
     * @dev Check if the transfer is an incentive claim
     * @return True if the transfer is a claim incentive, false otherwise
     */
    function _isClaimIncentive() internal returns (bool) {}

    /**
     * @dev Check if the user is verified on Self
     * @param _user The address of the user to check
     * @return True if the user is verified, false otherwise
     */
    function _isVerified(address _user) internal returns (bool) {}
}
