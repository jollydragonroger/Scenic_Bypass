// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract UltraMinimalHarmonic {
    
    // Fibonacci sequence (shortened for gas efficiency)
    uint256[6] public fibonacci = [233, 144, 89, 55, 34, 21];
    uint256 public index = 0;
    uint256 public resonance = 783;
    
    // Minimal investment tracking
    mapping(address => uint256) public invested;
    address[] public investors;
    
    // Events
    event HarmonicCycle(uint256 indexed cycle, uint256 value, uint256 res);
    event Invested(address indexed who, uint256 amount);
    
    function executeCycle() external {
        uint256 val = fibonacci[index];
        index = (index + 1) % 6;
        uint256 next = fibonacci[index];
        
        // Calculate resonance
        resonance = (val * 1000) / next;
        if (resonance > 2000) resonance = 2000;
        if (resonance < 500) resonance = 500;
        
        emit HarmonicCycle(index, next, resonance);
    }
    
    function invest() external payable {
        require(msg.value > 0, "Need ETH");
        if (invested[msg.sender] == 0) {
            investors.push(msg.sender);
        }
        invested[msg.sender] += msg.value;
        emit Invested(msg.sender, msg.value);
    }
    
    function getFibonacci() external view returns (uint256) {
        return fibonacci[index];
    }
    
    function getResonance() external view returns (uint256) {
        return resonance;
    }
    
    function getInvestors() external view returns (uint256) {
        return investors.length;
    }
}
