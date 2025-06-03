// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VerifiedERC20Factory} from "../src/VerifiedERC20Factory.sol";

contract DeployVerifiedERC20 is Script {
    struct DeploymentParams {
        address hookRegistryManager;
        string outputFilename;
    }

    VerifiedERC20Factory public verifiedERC20Factory;
    address public hookRegistry; //placeholder
    DeploymentParams internal _params;

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
        hookRegistry = address(1); // Placeholder for hook registry address
        verifiedERC20Factory = new VerifiedERC20Factory({_hookRegistry: hookRegistry});
    }

    function params() external view returns (DeploymentParams memory) {
        return _params;
    }

    function logParams() internal view virtual {
        console.log("VerifiedERC20Factory: ", address(verifiedERC20Factory));
    }

    function logOutput() internal virtual {
        if (isTest) return;
        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/deployment-addresses/", _params.outputFilename));
        vm.writeJson(vm.toString(address(verifiedERC20Factory)), path, ".verifiedERC20Factory");
        vm.writeJson(vm.toString(hookRegistry), path, ".hookRegistry");
    }
}
