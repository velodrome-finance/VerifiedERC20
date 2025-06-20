// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {ExcessivelySafeCall} from "@nomad-xyz/src/ExcessivelySafeCall.sol";

import {IReward} from "../../interfaces/external/IReward.sol";
import {ISelfPassportSBT} from "../../interfaces/external/ISelfPassportSBT.sol";
import {IHookRegistry} from "../../interfaces/hooks/IHookRegistry.sol";
import {IHook} from "../../interfaces/hooks/IHook.sol";

import {BaseTransferHook} from "../BaseTransferHook.sol";

/**
 * @title SelfTransferHook
 * @dev Hook to restrict incentive claims to users verified on Self
 */
contract SelfTransferHook is BaseTransferHook {
    using ExcessivelySafeCall for address;

    /// @notice Address of the voter contract to check if a transfer is a claim incentive
    address public immutable voter;

    /// @notice The Self Passport SBT contract address
    address public immutable selfPassportSBT;

    /**
     * @notice Initializes the SelfTransferHook
     * @param _name Name for the hook
     * @param _voter address of the voter contract
     * @param _selfPassportSBT The address of the Self Passport SBT contract
     */
    constructor(string memory _name, address _voter, address _selfPassportSBT) BaseTransferHook(_name) {
        voter = _voter;
        selfPassportSBT = _selfPassportSBT;
    }

    /// @inheritdoc IHook
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
    function _check(address _caller, address _from, address _to, uint256 _amount) internal view override {
        if (_isClaimIncentive({_from: _from}) && !_isVerified({_user: _to})) {
            revert Hook_Revert({_params: abi.encode(_caller, _from, _to, _amount)});
        }
    }

    /**
     * @dev Check if the transfer is an incentive claim
     * @param _from The sender address
     * @return True if the transfer is a claim incentive, false otherwise
     */
    function _isClaimIncentive(address _from) internal view returns (bool) {
        (bool success, bytes memory data) = _from.excessivelySafeStaticCall({
            _gas: 5_000,
            _maxCopy: 32,
            _calldata: abi.encodeWithSelector(IReward.DURATION.selector)
        });

        if (!success || data.length < 32 || (abi.decode(data, (uint256)) != 7 days)) return false;

        (success, data) = _from.excessivelySafeStaticCall({
            _gas: 5_000,
            _maxCopy: 32,
            _calldata: abi.encodeWithSelector(IReward.voter.selector)
        });
        if (!success || data.length < 32 || voter != abi.decode(data, (address))) return false;

        return true;
    }

    /**
     * @dev Check if the user is verified on Self
     * @param _user The address of the user to check
     * @return True if the user is verified, false otherwise
     */
    function _isVerified(address _user) internal view returns (bool) {
        uint256 tokenId = ISelfPassportSBT(selfPassportSBT).getTokenIdByAddress({user: _user});

        return tokenId != 0 && ISelfPassportSBT(selfPassportSBT).isTokenValid({tokenId: tokenId});
    }
}
