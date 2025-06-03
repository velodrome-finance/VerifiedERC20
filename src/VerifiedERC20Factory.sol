// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";

import {IVerifiedERC20Factory} from "./interfaces/IVerifiedERC20Factory.sol";
import {VerifiedERC20} from "./VerifiedERC20.sol";

/**
 * @title VerifiedERC20Factory
 * @notice Factory contract for deploying VerifiedERC20 instances
 */
contract VerifiedERC20Factory is IVerifiedERC20Factory, ReentrancyGuardTransient {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @dev A set containing all VerifiedERC20s created by this factory
    EnumerableSet.AddressSet private _verifiedERC20s;
    /// @inheritdoc IVerifiedERC20Factory
    address public immutable implementation;
    /// @inheritdoc IVerifiedERC20Factory
    address public immutable hookRegistry;

    /**
     * @notice Constructor for the VerifiedERC20Factory
     * @param _hookRegistry The address of the hook registry
     */
    constructor(address _implementation, address _hookRegistry) {
        if (_hookRegistry == address(0)) revert VerifiedERC20Factory_HookRegistry_ZeroAddress();
        if (_implementation == address(0)) revert VerifiedERC20Factory_Implementation_ZeroAddress();
        implementation = _implementation;
        hookRegistry = _hookRegistry;
    }

    /// @inheritdoc IVerifiedERC20Factory
    function deployVerifiedERC20(string memory _name, string memory _symbol, address _owner, address[] memory _hooks)
        external
        nonReentrant
        returns (address)
    {
        // slither-disable-next-line encode-packed-collision
        bytes32 salt = keccak256(abi.encodePacked(block.chainid, _verifiedERC20s.length(), _name, _symbol, _owner));
        address verifiedERC20 = Clones.cloneDeterministic({implementation: implementation, salt: salt});
        VerifiedERC20(verifiedERC20).initialize({
            name_: _name,
            symbol_: _symbol,
            owner_: _owner,
            _hookRegistry: hookRegistry,
            _hooks: _hooks
        });

        // slither-disable-next-line unused-return
        _verifiedERC20s.add({value: verifiedERC20});

        emit VerifiedERC20Created({verifiedERC20: verifiedERC20});

        return verifiedERC20;
    }

    /// @inheritdoc IVerifiedERC20Factory
    function getVerifiedERC20Count() external view returns (uint256) {
        return _verifiedERC20s.length();
    }

    /// @inheritdoc IVerifiedERC20Factory
    function getVerifiedERC20At(uint256 _index) external view returns (address) {
        return _verifiedERC20s.at({index: _index});
    }

    /// @inheritdoc IVerifiedERC20Factory
    function isVerifiedERC20(address _verifiedERC20) external view returns (bool) {
        return _verifiedERC20s.contains({value: _verifiedERC20});
    }

    /// @inheritdoc IVerifiedERC20Factory
    function getAllVerifiedERC20s() external view returns (address[] memory) {
        return _verifiedERC20s.values();
    }
}
