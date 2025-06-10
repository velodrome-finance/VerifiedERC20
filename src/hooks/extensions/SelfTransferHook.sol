// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {ITransferHook} from "../../interfaces/hooks/ITransferHook.sol";

import {BaseBHook} from "../BaseBHook.sol";

// Interface for Self SBT contract
interface ISelfPassportSBT {
    function getTokenIdByAddress(address user) external view returns (uint256 tokenId);
    function isTokenValid(uint256 tokenId) external view returns (bool valid);
}

/**
 * @title SelfTransferHook
 * @dev Hook to restrict incentive claims to users verified on Self
 */
contract SelfTransferHook is BaseBHook {
    /// @notice The Self Passport SBT contract address
    address public immutable selfPassportSBT;

    /**
     * @notice Initializes the SelfTransferHook with the Self Passport SBT contract
     * @param _selfPassportSBT The address of the Self Passport SBT contract
     */
    constructor(address _selfPassportSBT) {
        selfPassportSBT = _selfPassportSBT;
    }

    /**
     * @dev Restrict transfers to only allow verified users to claim incentives
     * @param _caller The address of the caller
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _amount The amount being transferred
     */
    function _check(address _caller, address _from, address _to, uint256 _amount) internal view override {
        if (_isClaimIncentive(_from, _to) && !_isVerified(_to)) {
            revert Hook_Revert({_params: abi.encode(_caller, _from, _to, _amount)});
        }
    }

    /**
     * @dev Check if the transfer is an incentive claim
     * @param _from The sender address
     * @param _to The recipient address
     * @return True if the transfer is a claim incentive, false otherwise
     */
    function _isClaimIncentive(address _from, address _to) internal view returns (bool) {
        // TODO: Implement logic to check if transfer is from incentive contract
        // This will be implemented by the team based on their incentive contract identification strategy
    }

    /**
     * @dev Check if the user is verified on Self
     * @param _user The address of the user to check
     * @return True if the user is verified, false otherwise
     */
    function _isVerified(address _user) internal view returns (bool) {
        // Get the token ID associated with the user
        uint256 tokenId = ISelfPassportSBT(selfPassportSBT).getTokenIdByAddress(_user);
        
        // If no token ID (returns 0), user is not verified
        if (tokenId == 0) {
            return false;
        }
        
        // Check if the token is still valid (not expired)
        return ISelfPassportSBT(selfPassportSBT).isTokenValid(tokenId);
    }
}