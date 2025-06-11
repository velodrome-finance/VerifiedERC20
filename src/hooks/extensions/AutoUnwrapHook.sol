// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {ExcessivelySafeCall} from "@nomad-xyz/src/ExcessivelySafeCall.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IReward} from "../../interfaces/external/IReward.sol";
import {ISelfPassportSBT} from "../../interfaces/external/ISelfPassportSBT.sol";
import {IHookRegistry} from "../../interfaces/hooks/IHookRegistry.sol";
import {IERC20Lockbox} from "../../interfaces/external/IERC20Lockbox.sol";
import {IVerifiedERC20} from "../../interfaces/IVerifiedERC20.sol";

import {BaseTransferHook} from "../BaseTransferHook.sol";

/**
 * @title AutoUnwrapHook
 * @dev Hook to automatically unwrap the verifiedERC20 into the base token
 */
contract AutoUnwrapHook is BaseTransferHook {
    using SafeERC20 for IERC20;
    using SafeERC20 for IVerifiedERC20;
    using ExcessivelySafeCall for address;

    /// @notice Error thrown when a zero address is provided
    error AutoUnwrapHook_ZeroAddress();

    /// @notice Error thrown when the caller is not authorized to set the lockbox
    error AutoUnwrapHook_NotAuthorized(address _caller, address _verifiedERC20, address _lockbox);

    /// @notice Emitted when a lockbox is set for a verified ERC20
    event LockboxSet(address indexed verifiedERC20, address indexed lockbox);

    /// @notice Address of the voter contract to check if a transfer is a claim incentive
    address public immutable voter;

    /// @notice The Self Passport SBT contract address
    address public immutable selfPassportSBT;

    /// @notice Timestamp of the last executed auto unwrap action to prevent infite loop
    uint256 public lastExecuted;

    /// @notice Mapping of verified ERC20 addresses to their corresponding lockbox addresses
    mapping(address _verifiedERC20 => address _lockbox) public lockbox;

    /**
     * @notice Initializes the SelfTransferHook
     * @param _name Name for the hook
     * @param _voter address of the voter contract
     * @param _selfPassportSBT The address of the Self Passport SBT contract
     */
    constructor(
        string memory _name,
        address _voter,
        address _selfPassportSBT,
        address[] memory _verifiedERC20s,
        address[] memory _lockboxes
    ) BaseTransferHook(_name) {
        voter = _voter;
        selfPassportSBT = _selfPassportSBT;

        for (uint256 i = 0; i < _verifiedERC20s.length;) {
            if (_lockboxes[i] == address(0) || _verifiedERC20s[i] == address(0)) {
                revert AutoUnwrapHook_ZeroAddress();
            }
            _setLockbox({_verifiedERC20: _verifiedERC20s[i], _lockbox: _lockboxes[i]});
            unchecked {
                i++;
            }
        }
    }

    function supportsEntrypoint(IHookRegistry.Entrypoint _entrypoint) external pure override returns (bool) {
        return _entrypoint == IHookRegistry.Entrypoint.AFTER_TRANSFER;
    }

    function setLockbox(address _verifiedERC20, address _lockbox) external {
        if (_lockbox == address(0) || _verifiedERC20 == address(0)) {
            revert AutoUnwrapHook_ZeroAddress();
        }
        if (msg.sender != Ownable(_verifiedERC20).owner()) {
            revert AutoUnwrapHook_NotAuthorized({
                _caller: msg.sender,
                _verifiedERC20: _verifiedERC20,
                _lockbox: _lockbox
            });
        }

        _setLockbox({_verifiedERC20: _verifiedERC20, _lockbox: _lockbox});
    }

    function _setLockbox(address _verifiedERC20, address _lockbox) internal {
        lockbox[_verifiedERC20] = _lockbox;

        emit LockboxSet({verifiedERC20: _verifiedERC20, lockbox: _lockbox});
    }

    /**
     * @dev Automatically unwrap on claim incentive when the user is verified
     * @param _caller The address of the caller
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _amount The amount being transferred
     */
    function _check(address _caller, address _from, address _to, uint256 _amount) internal override {
        if (block.timestamp > lastExecuted && _isClaimIncentive({_from: _from}) && _isVerified({_user: _to})) {
            IVerifiedERC20 verifiedERC20 = IVerifiedERC20(msg.sender);
            IERC20Lockbox _lockbox = IERC20Lockbox(lockbox[msg.sender]);

            verifiedERC20.transferFrom({from: _to, to: address(this), value: _amount});
            verifiedERC20.safeIncreaseAllowance({spender: address(_lockbox), value: _amount});
            _lockbox.withdraw(_amount);
            _lockbox.ERC20().safeTransfer({to: _to, value: _amount});
            lastExecuted = block.timestamp;
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
