// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VerifiedERC20} from "../src/VerifiedERC20.sol";

contract DeployVerifiedERC20 is Script {
    struct VerifiedERC20DeploymentParams {
        string name;
        string symbol;
        string outputFilename;
    }

    VerifiedERC20 public verifiedERC20;
    VerifiedERC20DeploymentParams internal _params;

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
        verifiedERC20 = new VerifiedERC20({name_: _params.name, symbol_: _params.symbol});
    }

    function params() external view returns (VerifiedERC20DeploymentParams memory) {
        return _params;
    }

    function logParams() internal view virtual {
        console.log("VerifiedERC20: ", address(verifiedERC20));
    }

    function logOutput() internal virtual {
        if (isTest) return;
        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/deployment-addresses/", _params.outputFilename));
        vm.writeJson(vm.toString(address(verifiedERC20)), path, ".verifiedERC20");
    }
}
