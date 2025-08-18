// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {ILeafVoter} from "../src/interfaces/external/ILeafVoter.sol";

import {SelfTransferHook} from "../src/hooks/extensions/SelfTransferHook.sol";

contract DeploySelfTransferHook is Script {
    struct SelfTransferHookDeploymentParams {
        string selfTransferHookName;
        address voter;
        address selfPassportSBT;
        string outputFilename;
    }

    SelfTransferHook public selfTransferHook;
    SelfTransferHookDeploymentParams internal _params;

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
        selfTransferHook = new SelfTransferHook({
            _name: _params.selfTransferHookName,
            _voter: _params.voter,
            _authorized: _getSelfDeploymentRewardsAuthorized(),
            _selfPassportSBT: _params.selfPassportSBT
        });
    }

    function logParams() internal view virtual {
        console.log("SelfTransferHook: ", address(selfTransferHook));
    }

    function logOutput() internal virtual {
        if (isTest) return;
        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/deployment-addresses/", _params.outputFilename));
        vm.writeJson(vm.toString(address(selfTransferHook)), path, ".SelfTransferHook");
    }

    function _getSelfDeploymentRewardsAuthorized() internal view returns (address) {
        return block.chainid == 10
            ? _params.voter //voter
            : ILeafVoter(_params.voter).bridge(); //leaf message bridge
    }
}
