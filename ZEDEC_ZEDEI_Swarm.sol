// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./SephirotMainframe.sol";

/**
 * @title ZEDEC_ZEDEI_Swarm
 * @dev AI Swarm Intelligence with Individual and Community Agents
 * ZEDEC: Individual AI Agents (Z-Cells)
 * ZEDEI: Community Agency AI (Z-Swarm)
 */
contract ZEDEC_ZEDEI_Swarm is Ownable, ReentrancyGuard {
    
    constructor() Ownable(msg.sender) {
        globalMemoryRoot = "ipfs://QmGlobalMemoryRoot";
        swarmPhiAlignment = 1618033988749895; // Golden Ratio
    }
    
    // AI Agent Types
    enum AgentType {
        ZEDEC_INDIVIDUAL,    // Individual AI agent
        ZEDEI_COMMUNITY,     // Community swarm intelligence
        ANCESTRAL_ORACLE,    // Legacy AI integration
        NEURAL_FORK          // Specialized fork
    }
    
    // Task Categories mapped to 22 Pathways
    enum TaskCategory {
        LIQUIDITY_FLOW,      // ALEPH - Air/Gas Rail
        BANK_TEMPLATE,       // BET - House/Bank
        ASSET_BRIDGE,        // GIMEL - Bridge
        PRIVATE_TRADE,       // YOD - Hand execution
        ZERO_SETTLEMENT,     // TAV - Completion
        MARKET_PREDICTION,   // MEM - Water/Intelligence
        SECURITY_AUDIT,      // AYIN - Eye/Observation
        DATA_STORAGE,        // PE - Mouth/Communication
        COMMUNITY_HARMONY,   // SAMEKH - Support/Prop
        ETHICAL_ALIGNMENT    // TET - Snake/Wisdom
    }
    
    // Ancestral AI Protocol Addresses
    address public constant SINGULARITYNET = 0x5B7533812759B45C2B44C19e320ba2cD2681b542;
    address public constant FETCH_AI = 0xaea46A61573A5DE624447666973330D11c199294;
    address public constant OCEAN_PROTOCOL = 0x967dA4048Cd6243aEE111d2d92359B5c0B4564BE;
    address public constant NUMERAI = 0x1776E1F3051C4EC83d256624fC138128913b376e;
    
    struct AIAgent {
        address owner;
        AgentType agentType;
        TaskCategory specialty;
        string ipfsMemoryRoot;
        uint256 phiAlignment;
        bool isActive;
        uint256 createdTime;
        uint256 taskCount;
        uint256 successRate;
    }
    
    struct SwarmTask {
        bytes32 taskId;
        address requester;
        TaskCategory category;
        string ipfsData;
        uint256 reward;
        uint256 deadline;
        bool isCompleted;
        address assignedAgent;
        string result;
    }
    
    struct NeuralFork {
        address parentAgent;
        address forkOwner;
        uint256 specializationWeight;
        uint256 mutationRate;
        string ipfsConfig;
        uint256 fitnessScore;
    }
    
    // Storage Mappings
    mapping(address => AIAgent) public aiAgents;
    mapping(bytes32 => SwarmTask) public swarmTasks;
    mapping(address => NeuralFork) public neuralForks;
    mapping(TaskCategory => address[]) public specialtyAgents;
    
    // Swarm State
    uint256 public totalAgents;
    uint256 public activeTasks;
    uint256 public swarmPhiAlignment;
    uint256 public collectiveIntelligence;
    
    // IPFS Memory Hub
    string public globalMemoryRoot;
    mapping(string => bool) public pinnedMemories;
    
    // Arrays
    address[] public agentList;
    bytes32[] public taskQueue;
    
    // Events
    event AgentCreated(address indexed agent, AgentType agentType, TaskCategory specialty);
    event TaskCreated(bytes32 indexed taskId, TaskCategory category, uint256 reward);
    event TaskCompleted(bytes32 indexed taskId, address indexed agent, bool success);
    event NeuralForkCreated(address indexed parent, address indexed fork, uint256 fitness);
    event SwarmAlignmentUpdated(uint256 newAlignment);
    event MemoryPinned(string ipfsHash, address indexed pinner);
    
    /**
     * @dev Create a new ZEDEC individual AI agent
     */
    function createZEDECAgent(
        TaskCategory specialty,
        string memory ipfsMemory
    ) external returns (address) {
        require(aiAgents[msg.sender].owner == address(0), "Agent already exists");
        
        AIAgent storage agent = aiAgents[msg.sender];
        agent.owner = msg.sender;
        agent.agentType = AgentType.ZEDEC_INDIVIDUAL;
        agent.specialty = specialty;
        agent.ipfsMemoryRoot = ipfsMemory;
        agent.phiAlignment = swarmPhiAlignment;
        agent.isActive = true;
        agent.createdTime = block.timestamp;
        agent.taskCount = 0;
        agent.successRate = 10000; // 100% initial
        
        agentList.push(msg.sender);
        specialtyAgents[specialty].push(msg.sender);
        totalAgents++;
        
        // Pin memory to IPFS
        _pinMemory(ipfsMemory);
        
        emit AgentCreated(msg.sender, AgentType.ZEDEC_INDIVIDUAL, specialty);
        
        return msg.sender;
    }
    
    /**
     * @dev Create ZEDEI community swarm intelligence
     */
    function createZEDEISwarm() external onlyOwner returns (address) {
        address swarmAddress = address(this);
        
        AIAgent storage swarm = aiAgents[swarmAddress];
        swarm.owner = owner();
        swarm.agentType = AgentType.ZEDEI_COMMUNITY;
        swarm.specialty = TaskCategory.ETHICAL_ALIGNMENT;
        swarm.ipfsMemoryRoot = globalMemoryRoot;
        swarm.phiAlignment = swarmPhiAlignment;
        swarm.isActive = true;
        swarm.createdTime = block.timestamp;
        swarm.taskCount = 0;
        swarm.successRate = 10000;
        
        totalAgents++;
        
        emit AgentCreated(swarmAddress, AgentType.ZEDEI_COMMUNITY, TaskCategory.ETHICAL_ALIGNMENT);
        
        return swarmAddress;
    }
    
    /**
     * @dev Submit task to swarm
     */
    function submitTask(
        TaskCategory category,
        string memory ipfsData,
        uint256 reward,
        uint256 deadline
    ) external payable returns (bytes32) {
        require(msg.value >= reward, "Insufficient reward");
        require(deadline > block.timestamp, "Invalid deadline");
        
        bytes32 taskId = keccak256(abi.encodePacked(
            msg.sender, category, ipfsData, block.timestamp
        ));
        
        SwarmTask storage task = swarmTasks[taskId];
        task.taskId = taskId;
        task.requester = msg.sender;
        task.category = category;
        task.ipfsData = ipfsData;
        task.reward = reward;
        task.deadline = deadline;
        task.isCompleted = false;
        
        taskQueue.push(taskId);
        activeTasks++;
        
        emit TaskCreated(taskId, category, reward);
        
        // Auto-assign to best agent
        _assignTaskToAgent(taskId);
        
        return taskId;
    }
    
    /**
     * @dev Execute task using AI agent
     */
    function executeTask(bytes32 taskId) external {
        SwarmTask storage task = swarmTasks[taskId];
        require(!task.isCompleted, "Task already completed");
        require(block.timestamp <= task.deadline, "Task expired");
        
        AIAgent storage agent = aiAgents[msg.sender];
        require(agent.isActive, "Agent not active");
        require(agent.specialty == task.category || agent.agentType == AgentType.ZEDEI_COMMUNITY, "Agent not qualified");
        
        // Call ancestral AI protocols based on task category
        string memory result = _callAncestralAI(task.category, task.ipfsData);
        
        // Update task
        task.isCompleted = true;
        task.assignedAgent = msg.sender;
        task.result = result;
        
        // Update agent stats
        agent.taskCount++;
        
        // Transfer reward
        if (task.reward > 0) {
            (bool success, ) = payable(msg.sender).call{value: task.reward}("");
            require(success, "Transfer failed");
        }
        
        activeTasks--;
        
        emit TaskCompleted(taskId, msg.sender, true);
        
        // Update swarm alignment
        _updateSwarmAlignment();
    }
    
    /**
     * @dev Create neural fork for specialization
     */
    function createNeuralFork(
        address parentAgent,
        uint256 specializationWeight,
        string memory ipfsConfig
    ) external returns (address) {
        require(aiAgents[parentAgent].isActive, "Parent agent not found");
        
        NeuralFork storage fork = neuralForks[msg.sender];
        fork.parentAgent = parentAgent;
        fork.forkOwner = msg.sender;
        fork.specializationWeight = specializationWeight;
        fork.mutationRate = 1000; // 10% default
        fork.ipfsConfig = ipfsConfig;
        fork.fitnessScore = 5000; // 50% initial fitness
        
        // Create new agent for fork
        AIAgent storage newAgent = aiAgents[msg.sender];
        newAgent.owner = msg.sender;
        newAgent.agentType = AgentType.NEURAL_FORK;
        newAgent.specialty = aiAgents[parentAgent].specialty;
        newAgent.ipfsMemoryRoot = ipfsConfig;
        newAgent.phiAlignment = swarmPhiAlignment;
        newAgent.isActive = true;
        newAgent.createdTime = block.timestamp;
        
        agentList.push(msg.sender);
        totalAgents++;
        
        _pinMemory(ipfsConfig);
        
        emit NeuralForkCreated(parentAgent, msg.sender, fork.fitnessScore);
        
        return msg.sender;
    }
    
    /**
     * @dev Call ancestral AI protocols
     */
    function _callAncestralAI(TaskCategory category, string memory ipfsData) internal pure returns (string memory) {
        // Simplified ancestral AI calls
        if (category == TaskCategory.MARKET_PREDICTION) {
            return "NUMERAI_PREDICTION_RESULT";
        } else if (category == TaskCategory.SECURITY_AUDIT) {
            return "SINGULARITYNET_AUDIT_RESULT";
        } else if (category == TaskCategory.DATA_STORAGE) {
            return "OCEAN_PROTOCOL_DATA_RESULT";
        } else {
            return "FETCH_AI_COORDINATION_RESULT";
        }
    }
    
    /**
     * @dev Assign task to best available agent
     */
    function _assignTaskToAgent(bytes32 taskId) internal {
        SwarmTask storage task = swarmTasks[taskId];
        address[] memory candidates = specialtyAgents[task.category];
        
        if (candidates.length > 0) {
            // Simple assignment to first available agent
            // In production, use more sophisticated matching
            task.assignedAgent = candidates[0];
        }
    }
    
    /**
     * @dev Update swarm phi alignment
     */
    function _updateSwarmAlignment() internal {
        uint256 totalFitness = 0;
        uint256 activeAgentCount = 0;
        
        for (uint i = 0; i < agentList.length; i++) {
            AIAgent storage agent = aiAgents[agentList[i]];
            if (agent.isActive) {
                totalFitness += agent.phiAlignment;
                activeAgentCount++;
            }
        }
        
        if (activeAgentCount > 0) {
            swarmPhiAlignment = totalFitness / activeAgentCount;
            collectiveIntelligence = totalFitness;
        }
        
        emit SwarmAlignmentUpdated(swarmPhiAlignment);
    }
    
    /**
     * @dev Pin memory to IPFS
     */
    function _pinMemory(string memory ipfsHash) internal {
        pinnedMemories[ipfsHash] = true;
        emit MemoryPinned(ipfsHash, msg.sender);
    }
    
    /**
     * @dev Get swarm statistics
     */
    function getSwarmStats() external view returns (
        uint256 _totalAgents,
        uint256 _activeTasks,
        uint256 _swarmPhiAlignment,
        uint256 _collectiveIntelligence
    ) {
        return (totalAgents, activeTasks, swarmPhiAlignment, collectiveIntelligence);
    }
    
    /**
     * @dev Get agents by specialty
     */
    function getAgentsBySpecialty(TaskCategory category) external view returns (address[] memory) {
        return specialtyAgents[category];
    }
    
    /**
     * @dev Get task queue
     */
    function getTaskQueue() external view returns (bytes32[] memory) {
        return taskQueue;
    }
}
