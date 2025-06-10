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
        string singlePermissionMintHookName;
        string singlePermissionBurnHookName;
        string selfTransferHookName;
        address verifiedERC20Factory;
        string outputFilename;
    }

    ERC20Lockbox public lockbox;
    SinglePermissionHook public singlePermissionMintHook;
    SinglePermissionHook public singlePermissionBurnHook;
    SelfTransferHook public selfTransferHook;
    VerifiedERC20 public verifiedERC20;
    SelfDeploymentParams internal _params;

    /// @dev Used by tests to disable logging of output
    bool public isTest;

    function run() external {
        vm.startBroadcast();

        deploy();
        logParams();
        logOutput();

        vm.stopBroadcast();
    }

    function deploy() internal virtual {
        VerifiedERC20Factory verifiedERC20Factory = VerifiedERC20Factory(_params.verifiedERC20Factory);
        verifiedERC20 = VerifiedERC20(
            verifiedERC20Factory.deployVerifiedERC20({
                _name: _params.verifiedERC20Name,
                _symbol: _params.verifiedERC20Symbol,
                _owner: _params.verifiedERC20Owner,
                _hooks: new address[](0) // Hook will be added to registry and activated post deployment
            })
        );

        lockbox = new ERC20Lockbox({_verifiedERC20: address(verifiedERC20), _erc20: _params.celo});
        singlePermissionMintHook =
            new SinglePermissionHook({name: _params.singlePermissionMintHookName, _authorized: address(lockbox)});
        singlePermissionBurnHook =
            new SinglePermissionHook({name: _params.singlePermissionBurnHookName, _authorized: address(lockbox)});

        selfTransferHook = new SelfTransferHook({name: _params.selfTransferHookName});
    }

    function params() external view returns (SelfDeploymentParams memory) {
        return _params;
    }

    function logParams() internal view virtual {
        console.log("ERC20Lockbox: ", address(lockbox));
        console.log("SinglePermissionMintHook: ", address(singlePermissionMintHook));
        console.log("SinglePermissionBurnHook: ", address(singlePermissionBurnHook));
        console.log("SelfTransferHook: ", address(selfTransferHook));
        console.log("VerifiedERC20: ", address(verifiedERC20));
    }

    function logOutput() internal virtual {
        if (isTest) return;
        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/deployment-addresses/", _params.outputFilename));
        vm.writeJson(vm.toString(address(lockbox)), path, ".Lockbox");
        vm.writeJson(vm.toString(address(singlePermissionMintHook)), path, ".SinglePermissionMintHook");
        vm.writeJson(vm.toString(address(singlePermissionBurnHook)), path, ".SinglePermissionBurnHook");
        vm.writeJson(vm.toString(address(selfTransferHook)), path, ".SelfTransferHook");
        vm.writeJson(vm.toString(address(verifiedERC20)), path, ".VerifiedERC20");
    }
}
