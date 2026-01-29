// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/**
 * @title MinimalMachine - Ultra-minimal deployment that will definitely work
 * @notice Simple machine with no external dependencies
 * @dev Trust Root: 441110111613564144
 */

contract MinimalMachine {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    
    // Basic state
    bool public active;
    uint256 public timestamp;
    address public machineAddress;
    
    // Events
    event MachineActivated(uint256 timestamp);
    event MachineDeployed(uint256 timestamp);
    
    constructor() {
        DEPLOYER = msg.sender;
        active = false;
        timestamp = block.timestamp;
        machineAddress = address(this);
        
        emit MachineDeployed(block.timestamp);
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    // Activate the machine
    function activate() external onlyDeployer {
        require(!active, "Already active");
        
        active = true;
        timestamp = block.timestamp;
        
        emit MachineActivated(block.timestamp);
    }
    
    // Get machine info
    function getMachineInfo() external view returns (
        bool isActive,
        uint256 deployTime,
        address contractAddress
    ) {
        return (
            active,
            timestamp,
            machineAddress
        );
    }
    
    // Withdraw any ETH
    function withdraw() external onlyDeployer {
        (bool success, ) = payable(DEPLOYER).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
    // Receive function
    receive() external payable {}
}
