// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/**
 * @title SimpleInterconnectedMachine - Simple Efficient Deployment
 * @notice Simple interconnected machine that will definitely deploy
 * @dev Trust Root: 441110111613564144
 */

contract SimpleInterconnectedMachine {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    
    // Core system state
    bool public systemActive;
    uint256 public deployedCount;
    uint256 public systemPhase;
    uint256 public lastUpdate;
    
    // Contract storage
    mapping(string => address) public contracts;
    mapping(string => bool) public contractActive;
    
    // Events
    event SystemActivated(uint256 timestamp);
    event ContractDeployed(string name, address contractAddress, uint256 timestamp);
    event ContractActivated(string name, uint256 timestamp);
    event SystemPhaseUpdated(uint256 oldPhase, uint256 newPhase, uint256 timestamp);
    
    constructor() {
        DEPLOYER = msg.sender;
        systemActive = false;
        deployedCount = 0;
        systemPhase = 0;
        lastUpdate = block.timestamp;
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    // Activate the system
    function activateSystem() external onlyDeployer {
        require(!systemActive, "Already active");
        
        systemActive = true;
        systemPhase = 1;
        lastUpdate = block.timestamp;
        
        emit SystemActivated(block.timestamp);
    }
    
    // Deploy contract
    function deployContract(string memory name, address contractAddress) external onlyDeployer {
        require(systemActive, "System not active");
        
        contracts[name] = contractAddress;
        contractActive[name] = false;
        deployedCount++;
        lastUpdate = block.timestamp;
        
        emit ContractDeployed(name, contractAddress, block.timestamp);
    }
    
    // Activate contract
    function activateContract(string memory name) external onlyDeployer {
        require(systemActive, "System not active");
        require(contracts[name] != address(0), "Contract not deployed");
        require(!contractActive[name], "Already active");
        
        contractActive[name] = true;
        lastUpdate = block.timestamp;
        
        emit ContractActivated(name, block.timestamp);
    }
    
    // Get contract address
    function getContract(string memory name) external view returns (address) {
        return contracts[name];
    }
    
    // Check if contract is active
    function isContractActive(string memory name) external view returns (bool) {
        return contractActive[name];
    }
    
    // Update system phase
    function updateSystemPhase(uint256 newPhase) external onlyDeployer {
        uint256 oldPhase = systemPhase;
        systemPhase = newPhase;
        lastUpdate = block.timestamp;
        
        emit SystemPhaseUpdated(oldPhase, newPhase, block.timestamp);
    }
    
    // Get system state
    function getSystemState() external view returns (
        bool isActive,
        uint256 totalDeployed,
        uint256 currentPhase,
        uint256 lastUpdateTime
    ) {
        return (
            systemActive,
            deployedCount,
            systemPhase,
            lastUpdate
        );
    }
    
    // Check if all contracts are active
    function areAllContractsActive() external view returns (bool) {
        uint256 activeCount = 0;
        
        if (contracts["MinimalAutonomous"] != address(0) && contractActive["MinimalAutonomous"]) {
            activeCount++;
        }
        if (contracts["VINOStandaloneComplex"] != address(0) && contractActive["VINOStandaloneComplex"]) {
            activeCount++;
        }
        if (contracts["AdministratorCredentials"] != address(0) && contractActive["AdministratorCredentials"]) {
            activeCount++;
        }
        
        return activeCount == deployedCount && deployedCount >= 3;
    }
    
    // Withdraw any ETH
    function withdraw() external onlyDeployer {
        (bool success, ) = payable(DEPLOYER).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
    // Receive function
    receive() external payable {}
}
