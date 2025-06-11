// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

abstract contract TestConstants {
    uint256 public constant TOKEN_1 = 1e18;
    uint256 public constant USDC_1 = 1e6;
    uint256 public constant POOL_1 = 1e9;

    // maximum number of tokens, used in fuzzing
    uint256 public constant MAX_TOKENS = 1e40;
    uint256 public constant MAX_BPS = 10_000;

    address public constant CELO = 0x765DE816845861e75A25fCA122bb6898B8B1282a; //use cUSD in tests to avoid CELO/foundry issues
    address public constant VOTER = 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123;
    address public constant SELF_PASSPORT_SBT = address(0); //placeholder
}
