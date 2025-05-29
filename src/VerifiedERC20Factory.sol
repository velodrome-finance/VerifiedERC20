// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {IVerifiedERC20Factory} from "./interfaces/IVerifiedERC20Factory.sol";
import {VerifiedERC20} from "./VerifiedERC20.sol";

/**
 * @title VerifiedERC20Factory
 * @notice Factory contract for deploying VerifiedERC20 instances
 */
contract VerifiedERC20Factory is IVerifiedERC20Factory {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @dev A set containing all VerifiedERC20s created by this factory
    EnumerableSet.AddressSet private _verifiedERC20s;

    /// @inheritdoc IVerifiedERC20Factory
    address public immutable hookRegistry;

    /**
     * @notice Constructor for the VerifiedERC20Factory
     * @param _hookRegistry The address of the hook registry
     */
    constructor(address _hookRegistry) {
        if (_hookRegistry == address(0)) revert VerifiedERC20Factory_HookRegistry_ZeroAddress();
        hookRegistry = _hookRegistry;
    }

    /// @inheritdoc IVerifiedERC20Factory
    function deployVerifiedERC20(string memory _name, string memory _symbol, address _owner, address[] memory _hooks)
        external
        returns (address)
    {
        address verifiedERC20 = address(
            new VerifiedERC20({
                name_: _name,
                symbol_: _symbol,
                _hookRegistry: hookRegistry,
                _owner: _owner,
                _hooks: _hooks
            })
        );

        // Add the newly created VerifiedERC20 to the set
        _verifiedERC20s.add(verifiedERC20);

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
