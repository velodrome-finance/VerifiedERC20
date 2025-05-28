// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PermissionedERC20} from "../src/PermissionedERC20.sol";

contract DeployPermissionedERC20 is Script {
    struct PermissionedERC20DeploymentParams {
        string name;
        string symbol;
        string outputFilename;
    }

    PermissionedERC20 public permissionedERC20;
    PermissionedERC20DeploymentParams internal _params;

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
        permissionedERC20 = new PermissionedERC20({name_: _params.name, symbol_: _params.symbol});
    }

    function params() external view returns (PermissionedERC20DeploymentParams memory) {
        return _params;
    }

    function logParams() internal view virtual {
        console.log("PermissionedERC20: ", address(permissionedERC20));
    }

    function logOutput() internal virtual {
        if (isTest) return;
        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/deployment-addresses/", _params.outputFilename));
        vm.writeJson(vm.toString(address(permissionedERC20)), path, ".permissionedERC20");
    }
}
