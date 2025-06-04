// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IVerifiedERC20 is IERC20 {
    /**
     * @notice Activates a hook for the verifiedERC20 token
     * @param _hook Address of the hook to activate
     */
    function activateHook(address _hook) external;
}
