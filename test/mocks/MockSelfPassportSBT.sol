// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {ISelfPassportSBT} from "src/interfaces/external/ISelfPassportSBT.sol";

contract MockSelfPassportSBT is ISelfPassportSBT {
    mapping(address user => uint256 tokenId) public getTokenIdByAddress;
    mapping(uint256 tokenId => bool valid) public isTokenValid;

    function mint(address to, uint256 tokenId) external {
        getTokenIdByAddress[to] = tokenId;
        isTokenValid[tokenId] = true;
    }

    function burn(address from, uint256 tokenId) external {
        require(getTokenIdByAddress[from] == tokenId, "Token ID mismatch");
        delete isTokenValid[tokenId];
        delete getTokenIdByAddress[from];
    }
}
