// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./ZedecKernel.sol";

/**
 * @title GridChain5D
 * @dev 5-Dimensional Post-Quantum Blockchain with Emotional Metadata
 * Implements classical shard + quantum cluster + emotion index + jurisdiction + cosmic phase
 */
contract GridChain5D is Ownable, ReentrancyGuard, Pausable {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    // 5D Block structure
    struct Block5D {
        uint256 blockNumber;
        bytes32 hash;
        uint256 timestamp;
        uint256 phase;
        
        // 5 Dimensions
        uint256 classicalShard;
        uint256 quantumCluster;
        uint256 emotionIndex;
        uint256 jurisdiction;
        uint256 cosmicPhase;
        
        // Post-quantum components
        bytes32 kyberCommitment;
        bytes32 dilithiumSignature;
        bytes32 vortexBeacon;
        
        // Metadata
        address proposer;
        uint256[] validatorSet;
        mapping(uint256 => bool) validatorVotes;
        uint256 voteCount;
        bool finalized;
    }
    
    // Validator structure
    struct Validator {
        address addr;
        uint256 stake;
        uint256 credibility;
        uint256 emotionalCoherence;
        uint256 lastVotePhase;
        bool active;
    }
    
    // Emotional vector structure
    struct EmotionalVector {
        uint256 valence; // -100 to 100 (negative to positive)
        uint256 arousal; // 0 to 100 (calm to excited)
        uint256 dominance; // 0 to 100 (submissive to dominant)
        bytes32 genomicSignature;
        uint256 timestamp;
    }
    
    // Constants
    uint256 public constant MIN_STAKE = 1000 * 1e18; // Minimum 1000 tokens
    uint256 public constant VALIDATOR_THRESHOLD = 67; // 67% supermajority
    uint256 public constant EMOTIONAL_WEIGHT = 30; // 30% weight for emotional coherence
    uint256 public constant CREDIBILITY_WEIGHT = 40; // 40% weight for credibility
    uint256 public constant STAKE_WEIGHT = 30; // 30% weight for stake
    
    // State variables
    ZedecKernel public kernel;
    mapping(uint256 => Block5D) public blocks;
    mapping(address => Validator) public validators;
    mapping(uint256 => address[]) public shardValidators;
    mapping(uint256 => address[]) public quantumClusters;
    mapping(uint256 => EmotionalVector) public emotionalVectors;
    
    uint256 public totalBlocks;
    uint256 public totalValidators;
    uint256 public currentQuantumCluster;
    uint256 public currentShard;
    uint256 public globalEmotionalIndex;
    
    // Events
    event BlockProposed(uint256 indexed blockNumber, address indexed proposer);
    event BlockFinalized(uint256 indexed blockNumber, bytes32 hash);
    event ValidatorRegistered(address indexed validator, uint256 stake);
    event VoteCast(uint256 indexed blockNumber, address indexed validator, bool support);
    event EmotionalVectorUpdated(address indexed user, uint256 valence, uint256 arousal, uint256 dominance);
    event QuantumClusterRotated(uint256 newCluster);
    event ShardRotated(uint256 newShard);
    
    // Modifiers
    modifier onlyValidator() {
        require(validators[msg.sender].active, "GridChain5D: Not a validator");
        _;
    }
    
    modifier sufficientStake() {
        require(validators[msg.sender].stake >= MIN_STAKE, "GridChain5D: Insufficient stake");
        _;
    }
    
    modifier validEmotionalVector(uint256 valence, uint256 arousal, uint256 dominance) {
        require(valence <= 200, "GridChain5D: Invalid valence range");
        require(arousal <= 100, "GridChain5D: Invalid arousal range");
        require(dominance <= 100, "GridChain5D: Invalid dominance range");
        _;
    }
    
    constructor(address _kernelAddress) {
        kernel = ZedecKernel(_kernelAddress);
        totalBlocks = 0;
        currentShard = 0;
        currentQuantumCluster = 0;
        globalEmotionalIndex = 50; // Neutral starting point
    }
    
    /**
     * @dev Register as a validator
     */
    function registerValidator() external payable nonReentrant whenNotPaused {
        require(msg.value >= MIN_STAKE, "GridChain5D: Insufficient stake");
        require(!validators[msg.sender].active, "GridChain5D: Already registered");
        
        validators[msg.sender] = Validator({
            addr: msg.sender,
            stake: msg.value,
            credibility: 50, // Start with neutral credibility
            emotionalCoherence: 50, // Start with neutral coherence
            lastVotePhase: 0,
            active: true
        });
        
        totalValidators = totalValidators.add(1);
        
        // Assign to current shard and quantum cluster
        shardValidators[currentShard].push(msg.sender);
        quantumClusters[currentQuantumCluster].push(msg.sender);
        
        emit ValidatorRegistered(msg.sender, msg.value);
    }
    
    /**
     * @dev Propose new 5D block
     */
    function proposeBlock(
        bytes32 dataHash,
        uint256 emotionIndex,
        uint256 jurisdiction,
        bytes32 kyberCommitment,
        bytes32 dilithiumSignature
    ) external onlyValidator sufficientStake nonReentrant whenNotPaused returns (uint256) {
        require(emotionIndex <= 100, "GridChain5D: Invalid emotion index");
        require(jurisdiction < 256, "GridChain5D: Invalid jurisdiction");
        
        totalBlocks = totalBlocks.add(1);
        
        Block5D storage block5d = blocks[totalBlocks];
        block5d.blockNumber = totalBlocks;
        block5d.timestamp = block.timestamp;
        block5d.phase = kernel.globalPhase();
        block5d.classicalShard = currentShard;
        block5d.quantumCluster = currentQuantumCluster;
        block5d.emotionIndex = emotionIndex;
        block5d.jurisdiction = jurisdiction;
        block5d.cosmicPhase = kernel.globalPhase() % 9; // Vortex base-9
        block5d.kyberCommitment = kyberCommitment;
        block5d.dilithiumSignature = dilithiumSignature;
        block5d.vortexBeacon = _calculateVortexBeacon(totalBlocks);
        block5d.proposer = msg.sender;
        block5d.finalized = false;
        
        // Calculate block hash
        block5d.hash = keccak256(abi.encodePacked(
            totalBlocks,
            dataHash,
            block5d.timestamp,
            block5d.phase,
            block5d.classicalShard,
            block5d.quantumCluster,
            block5d.emotionIndex,
            block5d.jurisdiction,
            block5d.cosmicPhase,
            kyberCommitment,
            dilithiumSignature,
            block5d.vortexBeacon
        ));
        
        emit BlockProposed(totalBlocks, msg.sender);
        
        return totalBlocks;
    }
    
    /**
     * @dev Vote on proposed block
     */
    function voteBlock(uint256 blockNumber, bool support) external onlyValidator nonReentrant whenNotPaused {
        require(blockNumber <= totalBlocks, "GridChain5D: Block not found");
        require(!blocks[blockNumber].finalized, "GridChain5D: Block already finalized");
        require(!blocks[blockNumber].validatorVotes[msg.sender], "GridChain5D: Already voted");
        
        Block5D storage block5d = blocks[blockNumber];
        
        // Calculate vote weight
        uint256 voteWeight = _calculateVoteWeight(msg.sender);
        
        block5d.validatorVotes[msg.sender] = support;
        block5d.voteCount = block5d.voteCount.add(voteWeight);
        validators[msg.sender].lastVotePhase = kernel.globalPhase();
        
        emit VoteCast(blockNumber, msg.sender, support);
        
        // Check if block can be finalized
        if (block5d.voteCount >= VALIDATOR_THRESHOLD) {
            _finalizeBlock(blockNumber);
        }
    }
    
    /**
     * @dev Calculate vote weight based on stake, credibility, and emotional coherence
     */
    function _calculateVoteWeight(address validator) internal view returns (uint256) {
        Validator storage v = validators[validator];
        
        uint256 stakeWeight = v.stake.mul(STAKE_WEIGHT) / 100;
        uint256 credibilityWeight = uint256(v.credibility).mul(CREDIBILITY_WEIGHT) / 100;
        uint256 emotionalWeight = uint256(v.emotionalCoherence).mul(EMOTIONAL_WEIGHT) / 100;
        
        return stakeWeight.add(credibilityWeight).add(emotionalWeight);
    }
    
    /**
     * @dev Finalize block
     */
    function _finalizeBlock(uint256 blockNumber) internal {
        Block5D storage block5d = blocks[blockNumber];
        block5d.finalized = true;
        
        // Update global emotional index
        globalEmotionalIndex = (globalEmotionalIndex.add(block5d.emotionIndex)) / 2;
        
        // Rotate shards and quantum clusters periodically
        if (blockNumber % 100 == 0) {
            _rotateShard();
        }
        if (blockNumber % 50 == 0) {
            _rotateQuantumCluster();
        }
        
        emit BlockFinalized(blockNumber, block5d.hash);
    }
    
    /**
     * @dev Rotate to next shard
     */
    function _rotateShard() internal {
        currentShard = (currentShard.add(1)) % 10;
        emit ShardRotated(currentShard);
    }
    
    /**
     * @dev Rotate to next quantum cluster
     */
    function _rotateQuantumCluster() internal {
        currentQuantumCluster = (currentQuantumCluster.add(1)) % 5;
        emit QuantumClusterRotated(currentQuantumCluster);
    }
    
    /**
     * @dev Calculate vortex beacon using golden ratio
     */
    function _calculateVortexBeacon(uint256 blockNumber) internal pure returns (bytes32) {
        uint256 goldenRatio = 1618033988749894848; // φ * 10^18
        uint256 vortexValue = (blockNumber * goldenRatio) / 1e18;
        return keccak256(abi.encodePacked(vortexValue, blockNumber));
    }
    
    /**
     * @dev Update emotional vector
     */
    function updateEmotionalVector(
        uint256 valence,
        uint256 arousal,
        uint256 dominance
    ) external validEmotionalVector(valence, arousal, dominance) nonReentrant whenNotPaused {
        EmotionalVector storage vector = emotionalVectors[msg.sender];
        vector.valence = valence;
        vector.arousal = arousal;
        vector.dominance = dominance;
        vector.genomicSignature = keccak256(abi.encodePacked(valence, arousal, dominance, block.timestamp));
        vector.timestamp = block.timestamp;
        
        // Update validator emotional coherence
        if (validators[msg.sender].active) {
            uint256 coherence = _calculateEmotionalCoherence(valence, arousal, dominance);
            validators[msg.sender].emotionalCoherence = coherence;
        }
        
        emit EmotionalVectorUpdated(msg.sender, valence, arousal, dominance);
    }
    
    /**
     * @dev Calculate emotional coherence score
     */
    function _calculateEmotionalCoherence(uint256 valence, uint256 arousal, uint256 dominance) internal pure returns (uint256) {
        // Simple coherence calculation based on balance
        uint256 balance = 100;
        if (valence > 100) balance = balance.sub((valence - 100) / 2);
        if (valence < 100) balance = balance.sub((100 - valence) / 2);
        if (arousal > 50) balance = balance.sub((arousal - 50) / 2);
        if (dominance > 50) balance = balance.sub((dominance - 50) / 2);
        
        return balance;
    }
    
    /**
     * @dev Update validator credibility
     */
    function updateValidatorCredibility(address validator, uint256 newCredibility) external onlyOwner {
        require(validators[validator].active, "GridChain5D: Validator not found");
        require(newCredibility <= 100, "GridChain5D: Invalid credibility");
        validators[validator].credibility = newCredibility;
    }
    
    /**
     * @dev Get block information
     */
    function getBlockInfo(uint256 blockNumber) external view returns (
        uint256 number,
        bytes32 hash,
        uint256 timestamp,
        uint256 phase,
        uint256 classicalShard,
        uint256 quantumCluster,
        uint256 emotionIndex,
        uint256 jurisdiction,
        uint256 cosmicPhase,
        address proposer,
        bool finalized
    ) {
        Block5D storage block5d = blocks[blockNumber];
        return (
            block5d.blockNumber,
            block5d.hash,
            block5d.timestamp,
            block5d.phase,
            block5d.classicalShard,
            block5d.quantumCluster,
            block5d.emotionIndex,
            block5d.jurisdiction,
            block5d.cosmicPhase,
            block5d.proposer,
            block5d.finalized
        );
    }
    
    /**
     * @dev Get validator information
     */
    function getValidatorInfo(address validator) external view returns (
        uint256 stake,
        uint256 credibility,
        uint256 emotionalCoherence,
        uint256 lastVotePhase,
        bool active
    ) {
        Validator storage v = validators[validator];
        return (
            v.stake,
            v.credibility,
            v.emotionalCoherence,
            v.lastVotePhase,
            v.active
        );
    }
    
    /**
     * @dev Get emotional vector
     */
    function getEmotionalVector(address user) external view returns (
        uint256 valence,
        uint256 arousal,
        uint256 dominance,
        bytes32 genomicSignature,
        uint256 timestamp
    ) {
        EmotionalVector storage vector = emotionalVectors[user];
        return (
            vector.valence,
            vector.arousal,
            vector.dominance,
            vector.genomicSignature,
            vector.timestamp
        );
    }
    
    /**
     * @dev Get shard validators
     */
    function getShardValidators(uint256 shard) external view returns (address[] memory) {
        return shardValidators[shard];
    }
    
    /**
     * @dev Get quantum cluster validators
     */
    function getQuantumClusterValidators(uint256 cluster) external view returns (address[] memory) {
        return quantumClusters[cluster];
    }
}
