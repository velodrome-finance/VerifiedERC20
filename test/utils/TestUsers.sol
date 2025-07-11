// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

struct Users {
    // owner / general purpose admin
    address payable owner;
    // hook registry manager
    address payable hookRegistryManager;
    // User, used to initiate calls
    address payable alice;
    // User, used as recipient
    address payable bob;
    // User, used as malicious user
    address payable charlie;
    // User, used as deployer
    address payable deployer;
}
