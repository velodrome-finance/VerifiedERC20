// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {ICreateX} from "createX/ICreateX.sol";
import {CreateXLibrary} from "src/libraries/CreateXLibrary.sol";

import {HookRegistry} from "../src/hooks/HookRegistry.sol";
import {VerifiedERC20Factory} from "../src/VerifiedERC20Factory.sol";
import {VerifiedERC20} from "../src/VerifiedERC20.sol";

bytes11 constant VERIFIED_ERC20_FACTORY_ENTROPY = 0x0000000000000000000011;
bytes11 constant VERIFIED_ERC20_ENTROPY = 0x0000000000000000000012;
bytes11 constant HOOK_REGISTRY_ENTROPY = 0x0000000000000000000013;

contract DeployVerifiedERC20 is Script {
    using CreateXLibrary for bytes11;

    error InvalidAddress(address expected, address output);

    struct DeploymentParams {
        address hookRegistryManager;
        string outputFilename;
    }

    ICreateX public cx = ICreateX(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed);

    address public deployer = 0xB40E2614122B58EA426F28E37eB66B2AC8511F9e;

    VerifiedERC20 public verifiedERC20Implementation;
    VerifiedERC20Factory public verifiedERC20Factory;
    HookRegistry public hookRegistry;
    DeploymentParams internal _params;

    /// @dev Used by tests to disable logging of output
    bool public isTest;

    function setUp() public virtual {}

    function run() external {
        vm.startBroadcast(deployer);

        verifyCreate3();
        deploy();
        logParams();
        logOutput();

        vm.stopBroadcast();
    }

    function deploy() internal virtual {
        hookRegistry = HookRegistry(
            cx.deployCreate3({
                salt: HOOK_REGISTRY_ENTROPY.calculateSalt({_deployer: deployer}),
                initCode: abi.encodePacked(
                    type(HookRegistry).creationCode,
                    abi.encode(_params.hookRegistryManager) // hook registry manager
                )
            })
        );
        checkAddress({_entropy: HOOK_REGISTRY_ENTROPY, _output: address(hookRegistry)});

        verifiedERC20Implementation = VerifiedERC20(
            cx.deployCreate3({
                salt: VERIFIED_ERC20_ENTROPY.calculateSalt({_deployer: deployer}),
                initCode: abi.encodePacked(type(VerifiedERC20).creationCode)
            })
        );
        checkAddress({_entropy: VERIFIED_ERC20_ENTROPY, _output: address(verifiedERC20Implementation)});

        verifiedERC20Factory = VerifiedERC20Factory(
            cx.deployCreate3({
                salt: VERIFIED_ERC20_FACTORY_ENTROPY.calculateSalt({_deployer: deployer}),
                initCode: abi.encodePacked(
                    type(VerifiedERC20Factory).creationCode,
                    abi.encode(
                        verifiedERC20Implementation, // verified ERC20 implementation
                        hookRegistry // hook registry
                    )
                )
            })
        );

        checkAddress({_entropy: VERIFIED_ERC20_FACTORY_ENTROPY, _output: address(verifiedERC20Factory)});
    }

    function params() external view returns (DeploymentParams memory) {
        return _params;
    }

    function logParams() internal view virtual {
        console.log("HookRegistry: ", address(hookRegistry));
        console.log("VerifiedERC20Factory: ", address(verifiedERC20Factory));
    }

    function logOutput() internal virtual {
        if (isTest) return;
        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/deployment-addresses/", _params.outputFilename));
        vm.writeJson(vm.toString(address(verifiedERC20Factory)), path, ".verifiedERC20Factory");
        vm.writeJson(vm.toString(address(hookRegistry)), path, ".hookRegistry");
    }

    /// @dev Check if the computed address matches the address produced by the deployment
    function checkAddress(bytes11 _entropy, address _output) internal view {
        address computedAddress = _entropy.computeCreate3Address({_deployer: deployer});
        if (computedAddress != _output) {
            revert InvalidAddress(computedAddress, _output);
        }
    }

    function verifyCreate3() internal view {
        /// if not run locally
        if (block.chainid != 31337) {
            uint256 size;
            address contractAddress = address(cx);
            assembly {
                size := extcodesize(contractAddress)
            }

            bytes memory bytecode = new bytes(size);
            assembly {
                extcodecopy(contractAddress, add(bytecode, 32), 0, size)
            }

            assert(keccak256(bytecode) == bytes32(0xbd8a7ea8cfca7b4e5f5041d7d4b17bc317c5ce42cfbc42066a00cf26b43eb53f));
        }
    }
}
