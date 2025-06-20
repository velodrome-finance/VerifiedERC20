// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolFactory {
    function createPool(address tokenA, address tokenB, uint24 fee) external returns (address);
}
