// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";

import {TestConstants} from "./utils/TestConstants.sol";
import {Users} from "./utils/TestUsers.sol";

import {PermissionedERC20} from "../src/PermissionedERC20.sol";
import {TestPermissionedERC20Deployment} from "test/mocks/TestPermissionedERC20Deployment.sol";

abstract contract BaseFixture is Test, TestConstants {
    Users public users;

    // Contracts
    TestPermissionedERC20Deployment public permissionedERC20Deployment;
    PermissionedERC20 public permissionedERC20;

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
        permissionedERC20Deployment = new TestPermissionedERC20Deployment("PermissionedERC20", "PermissionedRC20", "");
        permissionedERC20Deployment.run();

        permissionedERC20 = permissionedERC20Deployment.permissionedERC20();
    }

    function labelContracts() internal {
        vm.label({account: address(permissionedERC20Deployment), newLabel: "PermissionedERC20Deployment"});
        vm.label({account: address(permissionedERC20), newLabel: "PermissionedERC20"});
    }
}
