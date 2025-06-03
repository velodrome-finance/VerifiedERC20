// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import {ICreateX} from "createX/ICreateX.sol";
import {CreateXLibrary} from "src/libraries/CreateXLibrary.sol";

import {TestConstants} from "./utils/TestConstants.sol";
import {Users} from "./utils/TestUsers.sol";

import {VerifiedERC20} from "../src/VerifiedERC20.sol";
import {VerifiedERC20Factory, IVerifiedERC20Factory} from "../src/VerifiedERC20Factory.sol";
import {TestVerifiedERC20Deployment} from "test/mocks/TestVerifiedERC20Deployment.sol";

abstract contract BaseForkFixture is Test, TestConstants {
    Users public users;

    ICreateX public cx = ICreateX(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed);

    // Contracts
    TestVerifiedERC20Deployment public verifiedERC20Deployment;
    address public hookRegistry;
    VerifiedERC20Factory public verifiedERC20Factory;
    VerifiedERC20 public verifiedERC20;

    function setUp() public virtual {
        vm.createSelectFork({urlOrAlias: "optimism", blockNumber: 123316800});
        createUsers();

        deployContracts();
        labelContracts();
    }

    function createUsers() internal {
        users = Users({
            owner: createUser("Owner"),
            hookRegistryManager: createUser("HookRegistryManager"),
            alice: createUser("Alice"),
            bob: createUser("Bob"),
            charlie: createUser("Charlie"),
            deployer: createUser("Deployer")
        });
    }

    function createUser(string memory name) internal returns (address payable user) {
        user = payable(makeAddr({name: name}));
        vm.deal({account: user, newBalance: TOKEN_1 * 1_000});
    }

    function deployContracts() internal {
        verifiedERC20Deployment =
            new TestVerifiedERC20Deployment({_hookRegistryManager: users.owner, _outputFilename: ""});
        verifiedERC20Deployment.run();

        verifiedERC20Factory = verifiedERC20Deployment.verifiedERC20Factory();
        verifiedERC20 = VerifiedERC20(
            verifiedERC20Factory.deployVerifiedERC20({
                _name: "VerifiedERC20",
                _symbol: "VerifiedERC20",
                _owner: users.owner,
                _hooks: new address[](0)
            })
        );
        hookRegistry = verifiedERC20Deployment.hookRegistry();
    }

    function labelContracts() internal {
        vm.label({account: address(verifiedERC20Deployment), newLabel: "VerifiedERC20Deployment"});
        vm.label({account: address(verifiedERC20), newLabel: "VerifiedERC20"});
    }
}
