// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IVerifiedERC20} from "./interfaces/IVerifiedERC20.sol";

contract VerifiedERC20 is ERC20, Ownable, Initializable, IVerifiedERC20 {
    address public hookRegistry;

    /// @dev ERC20 name and symbol
    // slither-disable-next-line shadowing-state
    string private _name;
    // slither-disable-next-line shadowing-state
    string private _symbol;

    constructor() ERC20("", "") Ownable(address(this)) {
        _disableInitializers();
    }

    /**
     * @notice Called on verifiedERC20 creation by verifiedERC20 factory
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param owner_ The owner of the token
     * @param _hookRegistry The address of the hook registry
     * @param _hooks The hooks to be activated
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_,
        address _hookRegistry,
        address[] memory _hooks
    ) external initializer {
        _name = name_;
        _symbol = symbol_;
        _transferOwnership({newOwner: owner_});
        /// @dev Hook registry zero address check is made in the factory
        // slither-disable-next-line missing-zero-check
        hookRegistry = _hookRegistry;
        for (uint256 i = 0; i < _hooks.length; i++) {
            _activateHook({_hook: _hooks[i]});
        }
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function activateHook(address _hook) external onlyOwner {
        _activateHook({_hook: _hook});
    }

    function _activateHook(address _hook) internal {
        // Logic to activate the hook
        // This is a placeholder;
    }

    function approve(address spender, uint256 value) public override(ERC20, IERC20) returns (bool) {
        return super.approve({spender: spender, value: value});
    }

    function mint(address _account, uint256 _value) external {
        _mint({account: _account, value: _value});
    }

    function burn(address _account, uint256 _value) external {
        _burn({account: _account, value: _value});
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0) && to != address(0)) {
            //before transfer
        }
        super._update({from: from, to: to, value: value});
        if (from != address(0) && to != address(0)) {
            //after transfer
        }
    }
}
