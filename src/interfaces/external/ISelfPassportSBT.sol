// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for Self SBT contract
interface ISelfPassportSBT {
    function getTokenIdByAddress(address user) external view returns (uint256 tokenId);
    function isTokenValid(uint256 tokenId) external view returns (bool valid);
}
