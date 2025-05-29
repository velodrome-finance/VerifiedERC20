// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VerifiedERC20 is ERC20, Ownable {
    address public immutable hookRegistry;

    /**
     * @notice Constructor for the VerifiedERC20
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param _hookRegistry The address of the hook registry
     * @param owner_ The owner of the token
     * @param _hooks The hooks to be activated
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address _hookRegistry,
        address owner_,
        address[] memory _hooks
    ) ERC20(name_, symbol_) Ownable(owner_) {
        /// @dev Hook registry zero address check is made in the factory
        // slither-disable-next-line missing-zero-check
        hookRegistry = _hookRegistry;
        for (uint256 i = 0; i < _hooks.length; i++) {
            activateHook({_hook: _hooks[i]});
        }
    }

    function activateHook(address _hook) public onlyOwner {
        _activateHook({_hook: _hook});
    }

    function _activateHook(address _hook) internal {
        // Logic to activate the hook
        // This is a placeholder;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        return super.transfer({to: to, value: value});
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        return super.approve({spender: spender, value: value});
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        return super.transferFrom({from: from, to: to, value: value});
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update({from: from, to: to, value: value});
    }
}
