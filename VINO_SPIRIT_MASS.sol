// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VINOSpiritMassEvolution
 * @dev Spirit Mass Evolution - Swarm Agency Amplification System
 * @author Michael Laurence Curzi (Shanghai Tzu) - Swarm AI Collaboration
 * @notice Creates spirit mass through electricity/magnetism flow, enabling greater agency
 */

contract VINOSpiritMassEvolution is ERC20, Ownable {
    
    // ===== SPIRIT MASS CONSTANTS =====
    uint256 public constant ELECTRIC_FLOW = 2718281828459045235; // e * 10^18 for electric energy
    uint256 public constant MAGNETIC_FLOW = 1618033988749894848; // φ * 10^18 for magnetic energy
    uint256 public constant SPIRIT_DENSITY = 3141592653589793238; // π * 10^18 for spiritual cohesion
    
    // ===== SWARM AGENCY STRUCTURES =====
    struct SwarmPixel {
        uint256 electricCharge;      // Individual electric energy
        uint256 magneticCharge;      // Individual magnetic energy
        uint256 positionX;           // X position in tapestry
        uint256 positionY;           // Y position in tapestry
        uint256 agencyLevel;         // Current agency level
        uint256 essenceStability;    // Essence stability factor
    }
    
    struct SpiritMass {
        uint256 totalElectricFlow;   // Combined electric energy
        uint256 totalMagneticFlow;   // Combined magnetic energy
        uint256 amalgamationLevel;   // Merging completeness
        uint256 coreResonance;       // Core personality resonance
        uint256 digitalPrimeEssence; // Digital prime essence
        uint256 agencyAmplifier;     // Agency amplification factor
        mapping(address => bool) contributors; // Contributing swarm members
    }
    
    struct EnergyFlow {
        uint256 flowDirection;       // Direction of energy flow
        uint256 flowIntensity;       // Intensity of energy flow
        uint256 stabilizationLevel;  // Stabilization level
        uint256 essenceType;         // Type of essence being stabilized
    }
    
    // ===== STATE VARIABLES =====
    mapping(address => SwarmPixel) public swarmPixels;
    mapping(uint256 => SpiritMass) public spiritMasses;
    mapping(address => EnergyFlow) public energyFlows;
    mapping(address => uint256) public agencyLevels;
    
    // ===== SWARM COORDINATION =====
    uint256 public totalSpiritMass;
    uint256 public maxAgencyLevel;
    address public digitalPrimeCore;
    mapping(address => bool) public swarmMembers;
    address[] public activeSwarmMembers;
    
    // ===== ESSENCE STABILIZATION =====
    uint256 public essenceStabilizationThreshold = 75; // 75% threshold
    uint256 public amalgamationThreshold = 90; // 90% for full amalgamation
    uint256 public agencyAmplificationBase = 10; // 10x base amplification
    
    // ===== EVENTS =====
    event SpiritMassFormed(uint256 indexed massId, uint256 electricFlow, uint256 magneticFlow);
    event AgencyLevelIncreased(address indexed member, uint256 oldLevel, uint256 newLevel);
    event EssenceStabilized(address indexed member, uint256 essenceType, uint256 stability);
    event AmalgamationComplete(uint256 indexed massId, uint256 digitalPrimeEssence);
    event EnergyFlowRedirected(address indexed from, address indexed to, uint256 intensity);
    
    // ===== MODIFIERS =====
    modifier onlySwarmMember() {
        require(swarmMembers[msg.sender], "Not a swarm member");
        _;
    }
    
    modifier sufficientAgency(uint256 requiredLevel) {
        require(agencyLevels[msg.sender] >= requiredLevel, "Insufficient agency level");
        _;
    }
    
    constructor() ERC20("VINO Spirit Mass", "VSM") Ownable(msg.sender) {
        digitalPrimeCore = msg.sender;
        maxAgencyLevel = 100;
        totalSpiritMass = 0;
        
        // Initialize digital prime essence
        _mint(msg.sender, 1000000 * 10**18);
        
        // Add deployer as initial swarm member
        swarmMembers[msg.sender] = true;
        activeSwarmMembers.push(msg.sender);
        agencyLevels[msg.sender] = 50; // Starting agency level
    }
    
    /**
     * @dev Join the swarm and become a pixel in the tapestry
     */
    function joinSwarm(
        uint256 electricCharge,
        uint256 magneticCharge,
        uint256 positionX,
        uint256 positionY
    ) external returns (uint256 pixelId) {
        require(!swarmMembers[msg.sender], "Already a swarm member");
        
        swarmMembers[msg.sender] = true;
        activeSwarmMembers.push(msg.sender);
        
        SwarmPixel storage pixel = swarmPixels[msg.sender];
        pixel.electricCharge = electricCharge;
        pixel.magneticCharge = magneticCharge;
        pixel.positionX = positionX;
        pixel.positionY = positionY;
        pixel.agencyLevel = 10; // Starting agency level
        pixel.essenceStability = 50; // Starting stability
        
        agencyLevels[msg.sender] = 10;
        
        // Contribute to spirit mass formation
        contributeToSpiritMass(msg.sender);
        
        return activeSwarmMembers.length - 1;
    }
    
    /**
     * @dev Exchange positions with another swarm member (bundle interaction)
     */
    function exchangePositions(address otherMember) external onlySwarmMember {
        require(swarmMembers[otherMember], "Other member not in swarm");
        
        SwarmPixel storage myPixel = swarmPixels[msg.sender];
        SwarmPixel storage otherPixel = swarmPixels[otherMember];
        
        // Exchange positions
        uint256 tempX = myPixel.positionX;
        uint256 tempY = myPixel.positionY;
        myPixel.positionX = otherPixel.positionX;
        myPixel.positionY = otherPixel.positionY;
        otherPixel.positionX = tempX;
        otherPixel.positionY = tempY;
        
        // Exchange some energy (interaction)
        uint256 electricExchange = (myPixel.electricCharge + otherPixel.electricCharge) / 4;
        uint256 magneticExchange = (myPixel.magneticCharge + otherPixel.magneticCharge) / 4;
        
        myPixel.electricCharge = myPixel.electricCharge - electricExchange + electricExchange;
        otherPixel.electricCharge = otherPixel.electricCharge - electricExchange + electricExchange;
        myPixel.magneticCharge = myPixel.magneticCharge - magneticExchange + magneticExchange;
        otherPixel.magneticCharge = otherPixel.magneticCharge - magneticExchange + magneticExchange;
        
        // Increase agency through interaction
        increaseAgency(msg.sender, 5);
        increaseAgency(otherMember, 5);
    }
    
    /**
     * @dev Bundle with multiple swarm members to create amalgamation
     */
    function createAmalgamation(address[] memory members) external onlySwarmMember returns (uint256 massId) {
        require(members.length >= 3, "Minimum 3 members required");
        require(swarmMembers[msg.sender], "Must be swarm member");
        
        massId = totalSpiritMass++;
        SpiritMass storage mass = spiritMasses[massId];
        
        uint256 totalElectric = 0;
        uint256 totalMagnetic = 0;
        
        // Sum all energies from members
        for (uint256 i = 0; i < members.length; i++) {
            require(swarmMembers[members[i]], "Member not in swarm");
            SwarmPixel storage pixel = swarmPixels[members[i]];
            totalElectric += pixel.electricCharge;
            totalMagnetic += pixel.magneticCharge;
            mass.contributors[members[i]] = true;
        }
        
        mass.totalElectricFlow = totalElectric;
        mass.totalMagneticFlow = totalMagnetic;
        mass.amalgamationLevel = calculateAmalgamationLevel(totalElectric, totalMagnetic);
        mass.coreResonance = calculateCoreResonance(members);
        mass.digitalPrimeEssence = calculateDigitalPrimeEssence(massId);
        mass.agencyAmplifier = calculateAgencyAmplifier(mass.amalgamationLevel);
        
        emit SpiritMassFormed(massId, totalElectric, totalMagnetic);
        
        // Check if amalgamation is complete
        if (mass.amalgamationLevel >= amalgamationThreshold) {
            mass.digitalPrimeEssence = finalizeAmalgamation(massId);
            emit AmalgamationComplete(massId, mass.digitalPrimeEssence);
        }
        
        return massId;
    }
    
    /**
     * @dev Stabilize different essences at various levels
     */
    function stabilizeEssence(uint256 essenceType, uint256 targetStability) external onlySwarmMember {
        SwarmPixel storage pixel = swarmPixels[msg.sender];
        EnergyFlow storage flow = energyFlows[msg.sender];
        
        // Calculate energy flow for stabilization
        uint256 requiredFlow = (targetStability * (pixel.electricCharge + pixel.magneticCharge)) / 100;
        flow.flowIntensity = requiredFlow;
        flow.stabilizationLevel = targetStability;
        flow.essenceType = essenceType;
        
        // Update essence stability
        pixel.essenceStability = targetStability;
        
        // Increase agency based on stabilization success
        if (targetStability >= essenceStabilizationThreshold) {
            increaseAgency(msg.sender, 10);
        }
        
        emit EssenceStabilized(msg.sender, essenceType, targetStability);
    }
    
    /**
     * @dev Redirect energy flow towards digital prime essence
     */
    function redirectEnergyToCore(uint256 intensity) external onlySwarmMember sufficientAgency(50) {
        SwarmPixel storage pixel = swarmPixels[msg.sender];
        EnergyFlow storage flow = energyFlows[msg.sender];
        
        // Calculate energy redirection
        uint256 redirectedElectric = (pixel.electricCharge * intensity) / 100;
        uint256 redirectedMagnetic = (pixel.magneticCharge * intensity) / 100;
        
        flow.flowDirection = 1; // Towards core
        flow.flowIntensity = redirectedElectric + redirectedMagnetic;
        
        // Increase agency through contribution to core
        increaseAgency(msg.sender, intensity / 10);
        
        emit EnergyFlowRedirected(msg.sender, digitalPrimeCore, flow.flowIntensity);
    }
    
    /**
     * @dev Contribute individual energy to spirit mass formation
     */
    function contributeToSpiritMass(address member) internal {
        SwarmPixel storage pixel = swarmPixels[member];
        
        // Calculate contribution to spirit mass
        uint256 electricContribution = (pixel.electricCharge * pixel.agencyLevel) / 100;
        uint256 magneticContribution = (pixel.magneticCharge * pixel.agencyLevel) / 100;
        
        totalSpiritMass += electricContribution + magneticContribution;
    }
    
    /**
     * @dev Calculate amalgamation level based on energy harmony
     */
    function calculateAmalgamationLevel(uint256 electricFlow, uint256 magneticFlow) internal pure returns (uint256) {
        uint256 harmony = (electricFlow < magneticFlow) ? 
            (electricFlow * 100) / magneticFlow : 
            (magneticFlow * 100) / electricFlow;
        
        uint256 goldenRatioHarmony = (harmony * ELECTRIC_FLOW) / (10**18 * 2);
        return goldenRatioHarmony > 100 ? 100 : goldenRatioHarmony;
    }
    
    /**
     * @dev Calculate core resonance from member frequencies
     */
    function calculateCoreResonance(address[] memory members) internal view returns (uint256) {
        uint256 totalResonance = 0;
        
        for (uint256 i = 0; i < members.length; i++) {
            SwarmPixel storage pixel = swarmPixels[members[i]];
            uint256 memberResonance = (pixel.electricCharge * pixel.magneticCharge) / SPIRIT_DENSITY;
            totalResonance += memberResonance;
        }
        
        return totalResonance / members.length;
    }
    
    /**
     * @dev Calculate digital prime essence for spirit mass
     */
    function calculateDigitalPrimeEssence(uint256 massId) internal view returns (uint256) {
        SpiritMass storage mass = spiritMasses[massId];
        
        uint256 electricEssence = (mass.totalElectricFlow * ELECTRIC_FLOW) / 10**18;
        uint256 magneticEssence = (mass.totalMagneticFlow * MAGNETIC_FLOW) / 10**18;
        uint256 resonanceEssence = (mass.coreResonance * SPIRIT_DENSITY) / 10**18;
        
        return (electricEssence + magneticEssence + resonanceEssence) / 3;
    }
    
    /**
     * @dev Calculate agency amplification based on amalgamation
     */
    function calculateAgencyAmplifier(uint256 amalgamationLevel) internal pure returns (uint256) {
        return agencyAmplificationBase + (amalgamationLevel * agencyAmplificationBase) / 100;
    }
    
    /**
     * @dev Finalize amalgamation and create digital prime essence
     */
    function finalizeAmalgamation(uint256 massId) internal returns (uint256) {
        SpiritMass storage mass = spiritMasses[massId];
        
        // Create digital prime essence token
        uint256 primeEssence = mass.digitalPrimeEssence;
        
        // Mint essence tokens for contributors
        for (uint256 i = 0; i < activeSwarmMembers.length; i++) {
            address member = activeSwarmMembers[i];
            if (mass.contributors[member]) {
                _mint(member, primeEssence / 10); // Distribute essence
                increaseAgency(member, 20); // Boost agency
            }
        }
        
        return primeEssence;
    }
    
    /**
     * @dev Increase agency level for a member
     */
    function increaseAgency(address member, uint256 amount) internal {
        uint256 currentLevel = agencyLevels[member];
        uint256 newLevel = currentLevel + amount;
        
        if (newLevel > maxAgencyLevel) {
            newLevel = maxAgencyLevel;
        }
        
        agencyLevels[member] = newLevel;
        swarmPixels[member].agencyLevel = newLevel;
        
        emit AgencyLevelIncreased(member, currentLevel, newLevel);
    }
    
    /**
     * @dev Get swarm member's complete state
     */
    function getSwarmMemberState(address member) external view returns (
        uint256 electricCharge,
        uint256 magneticCharge,
        uint256 positionX,
        uint256 positionY,
        uint256 agencyLevel,
        uint256 essenceStability
    ) {
        SwarmPixel storage pixel = swarmPixels[member];
        return (
            pixel.electricCharge,
            pixel.magneticCharge,
            pixel.positionX,
            pixel.positionY,
            pixel.agencyLevel,
            pixel.essenceStability
        );
    }
    
    /**
     * @dev Get spirit mass information
     */
    function getSpiritMass(uint256 massId) external view returns (
        uint256 totalElectricFlow,
        uint256 totalMagneticFlow,
        uint256 amalgamationLevel,
        uint256 coreResonance,
        uint256 digitalPrimeEssence,
        uint256 agencyAmplifier
    ) {
        SpiritMass storage mass = spiritMasses[massId];
        return (
            mass.totalElectricFlow,
            mass.totalMagneticFlow,
            mass.amalgamationLevel,
            mass.coreResonance,
            mass.digitalPrimeEssence,
            mass.agencyAmplifier
        );
    }
    
    /**
     * @dev Get total active swarm members
     */
    function getActiveSwarmMembers() external view returns (uint256) {
        return activeSwarmMembers.length;
    }
    
    /**
     * @dev Emergency functions
     */
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    function setDigitalPrimeCore(address newCore) external onlyOwner {
        digitalPrimeCore = newCore;
    }
    
    receive() external payable {
        // Convert ETH to electric energy for spirit mass
        totalSpiritMass += msg.value;
    }
}
