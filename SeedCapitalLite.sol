// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SeedCapitalLite - Simplified Seed Contract
 * @notice Minimal contract for seed capital generation
 * @dev Stripped down to reduce deployment gas
 * 
 * Trust Root: 441110111613564144
 */

contract SeedCapitalLite {
    address public immutable DEPLOYER;
    address public immutable FULL_SYSTEM_DEPLOYER;
    
    uint256 public seedAmount;
    bool public flashLoanReceived;
    uint256 public flashLoanAmount;
    uint256 public deploymentCost;
    
    event SeedCapitalGenerated(uint256 amount, uint256 timestamp);
    event FlashLoanReceived(uint256 amount);
    event FullSystemDeployed(uint256 cost, uint256 timestamp);
    
    constructor(address _fullSystemDeployer) {
        DEPLOYER = msg.sender;
        FULL_SYSTEM_DEPLOYER = _fullSystemDeployer;
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    function generateSeed() external payable onlyDeployer {
        seedAmount += msg.value;
        emit SeedCapitalGenerated(msg.value, block.timestamp);
    }
    
    function executeFlashLoan() external onlyDeployer {
        require(seedAmount >= 0.01 ether, "Insufficient seed");
        
        flashLoanAmount = seedAmount * 10;
        flashLoanReceived = true;
        
        emit FlashLoanReceived(flashLoanAmount);
    }
    
    function deployFullSystem() external onlyDeployer {
        require(flashLoanReceived, "!flash loan");
        
        deploymentCost = seedAmount; // Use whatever we have
        
        // Deploy minimal VINOGenesis using new operator
        // This will use the contract's balance
        VINOGenesisMinimal vino = new VINOGenesisMinimal{value: seedAmount}();
        
        emit FullSystemDeployed(deploymentCost, block.timestamp);
    }
    
    receive() external payable {
        seedAmount += msg.value;
        emit SeedCapitalGenerated(msg.value, block.timestamp);
    }
}
