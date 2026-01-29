// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VINOGenesisMinimal - Minimal VINO Core Contract
 * @notice Simplified version that can be deployed with minimal gas
 * @dev Trust Root: 441110111613564144
 */

contract VINOGenesisMinimal {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    
    event Mint(address indexed to, uint256 amount);
    
    constructor() {
        // Mint initial supply to deployer
        totalSupply = 1000000 * 1e18;
        balanceOf[msg.sender] = totalSupply;
        emit Mint(msg.sender, totalSupply);
    }
    
    function mint(address to, uint256 amount) external {
        require(msg.sender == tx.origin, "!deployer"); // Simple auth
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Mint(to, amount);
    }
    
    receive() external payable {}
}
