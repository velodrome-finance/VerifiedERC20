// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ExcessivelySafeCall} from "@nomad-xyz/src/ExcessivelySafeCall.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";

import {IVerifiedERC20} from "./interfaces/IVerifiedERC20.sol";
import {IHookRegistry} from "./interfaces/hooks/IHookRegistry.sol";
import {IHook} from "./interfaces/hooks/IHook.sol";

contract VerifiedERC20 is ERC20, Ownable, Initializable, ReentrancyGuardTransient, IVerifiedERC20 {
    using ExcessivelySafeCall for address;

    /// @inheritdoc IVerifiedERC20
    uint256 public constant MAX_HOOKS_PER_ENTRYPOINT = 8;
    /// @inheritdoc IVerifiedERC20
    uint256 public constant MAX_GAS_PER_HOOK = 200_000;

    /// @inheritdoc IVerifiedERC20
    address public hookRegistry;

    /// @dev ERC20 name and symbol
    // slither-disable-next-line shadowing-state
    string private _name;
    // slither-disable-next-line shadowing-state
    string private _symbol;

    /// Array of arrays to store hooks for each entrypoint
    /// Index maps to IHookRegistry.Entrypoint enum
    /// Hooks may not remain in the order they were activated
    address[][] internal _hooksByEntrypoint;

    /// @inheritdoc IVerifiedERC20
    mapping(address _hook => uint256) public hookToIndex;
    /// @inheritdoc IVerifiedERC20
    mapping(address _hook => IHookRegistry.Entrypoint) public hookToEntrypoint;
    /// @inheritdoc IVerifiedERC20
    mapping(address _hook => bool) public isHookActivated;

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
        _hooksByEntrypoint = new address[][](8);
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
        address _hookRegistry;
        if (!IHookRegistry(_hookRegistry).isHookRegistered({_hook: _hook})) {
            revert VerifiedERC20_InvalidHook({hook: _hook});
        }
        if (isHookActivated[_hook]) revert VerifiedERC20_HookAlreadyActivated({hook: _hook});

        IHookRegistry.Entrypoint entrypoint = IHookRegistry(_hookRegistry).hookEntrypoints({_hook: _hook});
        uint256 index = _hooksByEntrypoint[uint8(entrypoint)].length;

        if (index >= MAX_HOOKS_PER_ENTRYPOINT) revert VerifiedERC20_MaxHooksExceeded();

        _hooksByEntrypoint[uint8(entrypoint)].push(_hook);

        // Store hook metadata for efficient removal
        hookToIndex[_hook] = index;
        hookToEntrypoint[_hook] = entrypoint;
        isHookActivated[_hook] = true;

        emit HookActivated({hook: _hook, entrypoint: entrypoint});
    }

    /// @inheritdoc IVerifiedERC20
    function deactivateHook(address _hook) external onlyOwner {
        if (!isHookActivated[_hook]) revert VerifiedERC20_HookNotActivated({hook: _hook});

        IHookRegistry.Entrypoint entrypoint = hookToEntrypoint[_hook];
        uint256 index = hookToIndex[_hook];
        address[] storage hooks = _hooksByEntrypoint[uint8(entrypoint)];

        uint256 lastIndex = hooks.length - 1;

        /// @dev note: this reorders the hooks
        if (index != lastIndex) {
            address lastHook = hooks[lastIndex];
            hooks[index] = lastHook;
            hookToIndex[lastHook] = index;
        }

        hooks.pop();

        delete hookToIndex[_hook];
        delete hookToEntrypoint[_hook];
        delete isHookActivated[_hook];

        emit HookDeactivated({hook: _hook, entrypoint: entrypoint});
    }

    /// @inheritdoc IVerifiedERC20
    function getHooksForEntrypoint(IHookRegistry.Entrypoint _entrypoint)
        external
        view
        override
        returns (address[] memory)
    {
        return _hooksByEntrypoint[uint8(_entrypoint)];
    }

    /// @inheritdoc IVerifiedERC20
    function getHookAtIndex(IHookRegistry.Entrypoint _entrypoint, uint256 _index)
        external
        view
        override
        returns (address)
    {
        return _hooksByEntrypoint[uint8(_entrypoint)][_index];
    }

    /// @inheritdoc IVerifiedERC20
    function getHooksCountForEntrypoint(IHookRegistry.Entrypoint _entrypoint)
        external
        view
        override
        returns (uint256)
    {
        return _hooksByEntrypoint[uint8(_entrypoint)].length;
    }

    /**
     * @dev Checks all hooks for a given entrypoint
     * @param _params The encoded function params
     * @param _entrypoint The entrypoint to check hooks for
     */
    function _checkHooks(IHookRegistry.Entrypoint _entrypoint, bytes memory _params) internal {
        address[] storage hooks = _hooksByEntrypoint[uint8(_entrypoint)];
        uint256 hooksLength = hooks.length;

        for (uint256 i = 0; i < hooksLength;) {
            (bool success, bytes memory data) = hooks[i].excessivelySafeCall({
                _gas: 200_000,
                _value: 0,
                _maxCopy: 32,
                _calldata: abi.encodeWithSelector(IHook.check.selector, msg.sender, _params)
            });
            if (!success) revert VerifiedERC20_HookRevert({data: data});

            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IERC20
    function approve(address spender, uint256 value) public override(ERC20, IERC20) nonReentrant returns (bool) {
        _checkHooks({_entrypoint: IHookRegistry.Entrypoint.BEFORE_APPROVE, _params: abi.encode(spender, value)});
        bool result = super.approve({spender: spender, value: value});
        _checkHooks({_entrypoint: IHookRegistry.Entrypoint.AFTER_APPROVE, _params: abi.encode(spender, value)});
        return result;
    }

    /// @inheritdoc IVerifiedERC20
    function mint(address _account, uint256 _value) external nonReentrant {
        _checkHooks({_entrypoint: IHookRegistry.Entrypoint.BEFORE_MINT, _params: abi.encode(_account, _value)});
        _mint({account: _account, value: _value});
        _checkHooks({_entrypoint: IHookRegistry.Entrypoint.AFTER_MINT, _params: abi.encode(_account, _value)});
    }

    /// @inheritdoc IVerifiedERC20
    function burn(address _account, uint256 _value) external nonReentrant {
        _checkHooks({_entrypoint: IHookRegistry.Entrypoint.BEFORE_BURN, _params: abi.encode(_account, _value)});
        _burn({account: _account, value: _value});
        _checkHooks({_entrypoint: IHookRegistry.Entrypoint.AFTER_BURN, _params: abi.encode(_account, _value)});
    }

    /**
     * @dev Called on ERC20 to transfer a `value` amount of tokens from `from` to `to`. Overriden for transfers. Mints and burns are checked in mint/burn functions.
     * @param from Address to transfer the tokens from
     * @param to Address to transfer the tokens to
     * @param value Amount of tokens to transfer
     *
     */
    function _update(address from, address to, uint256 value) internal override {
        /// @dev If burn is called from different address, we need to check allowance
        if (to == address(0) && msg.sender != from) {
            _spendAllowance({owner: from, spender: msg.sender, value: value});
        }

        if (from != address(0) && to != address(0)) {
            _checkHooks({_entrypoint: IHookRegistry.Entrypoint.BEFORE_TRANSFER, _params: abi.encode(from, to, value)});
        }
        super._update({from: from, to: to, value: value});
        if (from != address(0) && to != address(0)) {
            _checkHooks({_entrypoint: IHookRegistry.Entrypoint.AFTER_TRANSFER, _params: abi.encode(from, to, value)});
        }
    }
}
