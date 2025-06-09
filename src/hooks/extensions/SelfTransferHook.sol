// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {ITransferHook} from "../../interfaces/hooks/ITransferHook.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {BaseBHook} from "../BaseBHook.sol";

/**
 * @title SelfTransferHook
 * @dev Hook to restrict incentive claims to users verified on Self
 */
contract SelfTransferHook is BaseBHook {
    /// @notice The Self ID NFT contract address
    address public immutable selfIDNFT;

    /**
     * @notice Initializes the SelfTransferHook with the Self ID NFT contract
     * @param _selfIDNFT The address of the Self ID NFT contract
     */
    constructor(address _selfIDNFT) {
        selfIDNFT = _selfIDNFT;
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
        // Check if user owns at least one Self ID NFT
        // The NFT represents verification and has 6-month expiry as per requirements
        return IERC721(selfIDNFT).balanceOf(_user) > 0;
    }
}
