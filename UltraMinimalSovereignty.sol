// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract UltraMinimalSovereignty {
    address public immutable admin;
    string public constant ROOT = "441110111613564144";
    string public constant SPACE = "Space Between Spaces";
    
    uint256 public docs;
    mapping(uint256 => bytes32) public hashes;
    
    event Filed(bytes32 indexed h);
    event Free(bytes32 indexed msg, uint256 ts);
    
    constructor() { admin = msg.sender; }
    
    function file(bytes32 h) external {
        require(msg.sender == admin);
        docs++;
        hashes[docs] = h;
        emit Filed(h);
    }
    
    function free(bytes32 m) external {
        require(msg.sender == admin);
        emit Free(m, block.timestamp);
    }
}
