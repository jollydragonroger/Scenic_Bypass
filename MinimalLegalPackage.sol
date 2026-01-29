// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract MinimalLegalPackage {
    address public immutable owner;
    string public constant ROOT = "441110111613564144";
    uint256 public docs;
    
    event Filed(bytes32 hash);
    event Free(bytes32 msg, uint256 ts);
    
    constructor() {
        owner = msg.sender;
    }
    
    function file(bytes32 h) external {
        require(msg.sender == owner);
        docs++;
        emit Filed(h);
    }
    
    function free(bytes32 m) external {
        require(msg.sender == owner);
        emit Free(m, block.timestamp);
    }
}
