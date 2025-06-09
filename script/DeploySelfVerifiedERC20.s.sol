// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {CreateXLibrary} from "../src/libraries/CreateXLibrary.sol";

import {VerifiedERC20Factory} from "../src/VerifiedERC20Factory.sol";
import {VerifiedERC20} from "../src/VerifiedERC20.sol";
import {ERC20Lockbox} from "../src/external/ERC20Lockbox.sol";
import {SelfTransferHook} from "../src/hooks/extensions/SelfTransferHook.sol";
import {SinglePermissionHook} from "../src/hooks/extensions/SinglePermissionHook.sol";

contract DeploySelfVerifiedERC20 is Script {
    using CreateXLibrary for bytes11;

    struct SelfDeploymentParams {
        string verifiedERC20Name;
        string verifiedERC20Symbol;
        address verifiedERC20Owner;
        address celo;
        string singlePermissionHookName;
        string selfTransferHookName;
        address verifiedERC20Factory;
        string outputFilename;
    }

    ERC20Lockbox public lockbox;
    SinglePermissionHook public singlePermissionHook;
    SelfTransferHook public selfTransferHook;
    VerifiedERC20 public verifiedERC20;
    SelfDeploymentParams internal _params;

    /// @dev Used by tests to disable logging of output
    bool public isTest;

    function setUp() public virtual {}

    function run() external {
        vm.startBroadcast();

        deploy();
        logParams();
        logOutput();

        vm.stopBroadcast();
    }

    function deploy() internal virtual {
        verifiedERC20 = VerifiedERC20(_predictedVerifiedERC20Address());

        lockbox = new ERC20Lockbox({_verifiedERC20: address(verifiedERC20), _erc20: _params.celo});
        singlePermissionHook =
            new SinglePermissionHook({name: _params.singlePermissionHookName, _authorized: address(lockbox)});
        selfTransferHook = new SelfTransferHook({name: _params.selfTransferHookName});

        address[] memory hooks = new address[](2);
        hooks[0] = address(singlePermissionHook);
        hooks[1] = address(selfTransferHook);

        VerifiedERC20Factory verifiedERC20Factory = VerifiedERC20Factory(_params.verifiedERC20Factory);
        verifiedERC20 = VerifiedERC20(
            verifiedERC20Factory.deployVerifiedERC20({
                _name: _params.verifiedERC20Name,
                _symbol: _params.verifiedERC20Symbol,
                _owner: _params.verifiedERC20Owner,
                _hooks: hooks
            })
        );
    }

    function params() external view returns (SelfDeploymentParams memory) {
        return _params;
    }

    function logParams() internal view virtual {
        console.log("ERC20Lockbox: ", address(lockbox));
        console.log("SinglePermissionHook: ", address(singlePermissionHook));
        console.log("SelfTransferHook: ", address(selfTransferHook));
        console.log("VerifiedERC20: ", address(verifiedERC20));
    }

    function logOutput() internal virtual {
        if (isTest) return;
        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/deployment-addresses/", _params.outputFilename));
        vm.writeJson(vm.toString(address(lockbox)), path, ".Lockbox");
        vm.writeJson(vm.toString(address(singlePermissionHook)), path, ".SinglePermissionHook");
        vm.writeJson(vm.toString(address(selfTransferHook)), path, ".SelfTransferHook");
        vm.writeJson(vm.toString(address(verifiedERC20)), path, ".VerifiedERC20");
    }

    function _predictedVerifiedERC20Address() internal view returns (address) {
        VerifiedERC20Factory verifiedERC20Factory = VerifiedERC20Factory(_params.verifiedERC20Factory);
        bytes32 salt = keccak256(
            abi.encodePacked(
                block.chainid,
                verifiedERC20Factory.getVerifiedERC20Count(),
                _params.verifiedERC20Name,
                _params.verifiedERC20Symbol,
                _params.verifiedERC20Owner
            )
        );
        bytes11 entropy = bytes11(salt);
        salt = entropy.calculateSalt({_deployer: address(verifiedERC20Factory)});
        bytes32 guardedSalt = keccak256(abi.encodePacked(uint256(uint160(address(verifiedERC20Factory))), salt));

        address expectedVerifiedERC20 = CreateXLibrary.CREATEX.computeCreate2Address({
            salt: guardedSalt,
            initCodeHash: keccak256(
                abi.encodePacked(
                    hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
                    bytes20(verifiedERC20Factory.implementation()),
                    hex"5af43d82803e903d91602b57fd5bf3"
                )
            ),
            deployer: address(CreateXLibrary.CREATEX)
        });

        return expectedVerifiedERC20;
    }
}
