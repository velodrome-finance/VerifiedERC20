// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";

import {TestConstants} from "./utils/TestConstants.sol";
import {Users} from "./utils/TestUsers.sol";

import {VerifiedERC20} from "../src/VerifiedERC20.sol";
import {TestVerifiedERC20Deployment} from "test/mocks/TestVerifiedERC20Deployment.sol";

abstract contract BaseFixture is Test, TestConstants {
    Users public users;

    // Contracts
    TestVerifiedERC20Deployment public verifiedERC20Deployment;
    VerifiedERC20 public verifiedERC20;

    function setUp() public virtual {
        createUsers();

        deployContracts();
        labelContracts();
    }

    function createUsers() internal {
        users = Users({
            owner: createUser("Owner"),
            feeManager: createUser("FeeManager"),
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
        verifiedERC20Deployment = new TestVerifiedERC20Deployment("VerifiedERC20", "VerifiedRC20", "");
        verifiedERC20Deployment.run();

        verifiedERC20 = verifiedERC20Deployment.verifiedERC20();
    }

    function labelContracts() internal {
        vm.label({account: address(verifiedERC20Deployment), newLabel: "VerifiedERC20Deployment"});
        vm.label({account: address(verifiedERC20), newLabel: "VerifiedERC20"});
    }
}
