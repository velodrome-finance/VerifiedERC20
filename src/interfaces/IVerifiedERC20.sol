// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IVerifiedERC20 is IERC20 {
    /**
     * @notice Activates a hook for the verifiedERC20 token
     * @param _hook Address of the hook to activate
     */
    function activateHook(address _hook) external;

    /**
     * @notice Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * @param _account The address to which the tokens will be minted
     * @param _value The amount of tokens to mint
     */
    function mint(address _account, uint256 _value) external;

    /**
     * @notice Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * @param _account The address from which the tokens will be burned
     * @param _value The amount of tokens to burn
     */
    function burn(address _account, uint256 _value) external;
}
