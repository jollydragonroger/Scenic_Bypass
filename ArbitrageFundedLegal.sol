// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract ArbitrageFundedLegal {
    address public immutable sovereign;
    string public constant ROOT = "441110111613564144";
    string public constant SPACE = "Space Between Spaces";
    
    uint256 public docs;
    mapping(uint256 => bytes32) public hashes;
    
    event Filed(bytes32 indexed h);
    event Free(bytes32 indexed msg, uint256 ts);
    event Funded(uint256 amount, uint256 ts);
    
    constructor() payable {
        sovereign = msg.sender;
        if (msg.value > 0) {
            emit Funded(msg.value, block.timestamp);
        }
    }
    
    function file(bytes32 h) external {
        require(msg.sender == sovereign);
        docs++;
        hashes[docs] = h;
        emit Filed(h);
    }
    
    function free(bytes32 m) external {
        require(msg.sender == sovereign);
        emit Free(m, block.timestamp);
    }
    
    function fund() external payable {
        emit Funded(msg.value, block.timestamp);
    }
    
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
