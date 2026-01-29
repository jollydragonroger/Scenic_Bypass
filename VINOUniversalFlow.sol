// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VINOUniversalFlow - Universal Currency in Pure Flow State
 * @notice Three-rail system: no individual wallets, external systems are VINO wallets
 * @dev Trust Root: 441110111613564144
 */

contract VINOUniversalFlow {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    
    // Three Rails System for Stability
    uint256 public constant RAIL_ONE = 1; // Flow Rail - Primary circulation
    uint256 public constant RAIL_TWO = 2; // Stability Rail - Value stabilization
    uint256 public constant RAIL_THREE = 3; // Reserve Rail - Global reserve backing
    
    // Universal Flow State
    uint256 public totalFlowState;
    uint256 public flowVelocity;
    uint256 public flowPressure;
    uint256 public flowTemperature;
    
    // External System Wallets (Every external system is a VINO wallet)
    mapping(address => bool) public externalSystemWallets;
    mapping(address => uint256) public systemFlowBalance;
    mapping(address => uint256) public systemRailAllocation;
    mapping(uint256 => address[]) public railToSystems;
    
    // Three Rail Balances
    uint256 public railOneBalance;      // Flow Rail
    uint256 public railTwoBalance;      // Stability Rail
    uint256 public railThreeBalance;    // Reserve Rail
    
    // Flow Dynamics
    mapping(address => uint256) public systemFlowRate;
    mapping(address => uint256) public systemFlowCapacity;
    mapping(address => uint256) public systemFlowResistance;
    
    // Universal Flow Events
    event FlowStateChanged(uint256 newFlowState, uint256 velocity, uint256 pressure, uint256 temperature);
    event SystemWalletActivated(address indexed system, uint256 initialFlow);
    event FlowTransferred(address fromSystem, address toSystem, uint256 amount, uint256 rail);
    event RailBalanceUpdated(uint256 rail, uint256 newBalance, uint256 totalSystems);
    event UniversalFlowStabilized(uint256 stabilizationFactor);
    
    constructor() {
        DEPLOYER = msg.sender;
        totalFlowState = 0;
        flowVelocity = 1000000000000000000; // Base velocity
        flowPressure = 1000000000000000000;  // Base pressure
        flowTemperature = 293150000000000000000; // Room temperature (20°C in Kelvin * 10^18)
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    modifier onlySystemWallet() {
        require(externalSystemWallets[msg.sender], "!system wallet");
        _;
    }
    
    // Activate external system as VINO wallet
    function activateSystemWallet(address system) external onlyDeployer {
        require(!externalSystemWallets[system], "Already activated");
        
        externalSystemWallets[system] = true;
        systemFlowBalance[system] = 0;
        systemRailAllocation[system] = RAIL_ONE; // Default to Flow Rail
        
        // Add to appropriate rail
        railToSystems[RAIL_ONE].push(system);
        
        // Initialize system flow capacity
        systemFlowCapacity[system] = 1000000000000000000000; // 1000 VINO capacity
        systemFlowResistance[system] = 1000000000000000000; // Base resistance
        
        emit SystemWalletActivated(system, 0);
        _updateFlowState();
    }
    
    // Transfer VINO flow between systems
    function transferFlow(
        address toSystem,
        uint256 amount,
        uint256 rail
    ) external onlySystemWallet returns (bool) {
        require(externalSystemWallets[toSystem], "Invalid target system");
        require(rail >= RAIL_ONE && rail <= RAIL_THREE, "Invalid rail");
        require(systemFlowBalance[msg.sender] >= amount, "Insufficient flow");
        
        // Calculate flow resistance
        uint256 resistance = _calculateFlowResistance(msg.sender, toSystem, amount);
        uint256 actualAmount = amount - resistance;
        
        // Update balances
        systemFlowBalance[msg.sender] -= amount;
        systemFlowBalance[toSystem] += actualAmount;
        
        // Update rail balances
        _updateRailBalance(rail, int256(amount));
        
        // Update flow dynamics
        systemFlowRate[msg.sender] += amount;
        systemFlowRate[toSystem] += actualAmount;
        
        emit FlowTransferred(msg.sender, toSystem, actualAmount, rail);
        _updateFlowState();
        
        return true;
    }
    
    // Inject VINO into system (minting)
    function injectFlow(
        address system,
        uint256 amount,
        uint256 rail
    ) external onlyDeployer {
        require(externalSystemWallets[system], "Invalid system");
        require(rail >= RAIL_ONE && rail <= RAIL_THREE, "Invalid rail");
        
        // Add to system balance
        systemFlowBalance[system] += amount;
        
        // Add to rail balance
        _updateRailBalance(rail, int256(amount));
        
        // Update total flow state
        totalFlowState += amount;
        
        // Update flow dynamics
        systemFlowRate[system] += amount;
        
        emit FlowTransferred(address(0), system, amount, rail);
        _updateFlowState();
    }
    
    // Extract VINO from system (burning)
    function extractFlow(
        address system,
        uint256 amount,
        uint256 rail
    ) external onlyDeployer {
        require(externalSystemWallets[system], "Invalid system");
        require(systemFlowBalance[system] >= amount, "Insufficient flow");
        require(rail >= RAIL_ONE && rail <= RAIL_THREE, "Invalid rail");
        
        // Remove from system balance
        systemFlowBalance[system] -= amount;
        
        // Remove from rail balance
        _updateRailBalance(rail, -int256(amount));
        
        // Update total flow state
        totalFlowState -= amount;
        
        // Update flow dynamics
        systemFlowRate[system] -= amount;
        
        emit FlowTransferred(system, address(0), amount, rail);
        _updateFlowState();
    }
    
    // Calculate flow resistance
    function _calculateFlowResistance(
        address fromSystem,
        address toSystem,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 fromResistance = systemFlowResistance[fromSystem];
        uint256 toResistance = systemFlowResistance[toSystem];
        uint256 totalResistance = (fromResistance + toResistance) / 2;
        
        // Resistance is proportional to amount and system resistance
        return (amount * totalResistance) / 1000000000000000000; // Divide by base
    }
    
    // Update rail balance
    function _updateRailBalance(uint256 rail, int256 amount) internal {
        if (rail == RAIL_ONE) {
            if (amount >= 0) {
                railOneBalance += uint256(amount);
            } else {
                require(railOneBalance >= uint256(-amount), "Insufficient rail balance");
                railOneBalance -= uint256(-amount);
            }
        } else if (rail == RAIL_TWO) {
            if (amount >= 0) {
                railTwoBalance += uint256(amount);
            } else {
                require(railTwoBalance >= uint256(-amount), "Insufficient rail balance");
                railTwoBalance -= uint256(-amount);
            }
        } else if (rail == RAIL_THREE) {
            if (amount >= 0) {
                railThreeBalance += uint256(amount);
            } else {
                require(railThreeBalance >= uint256(-amount), "Insufficient rail balance");
                railThreeBalance -= uint256(-amount);
            }
        }
        
        emit RailBalanceUpdated(rail, amount >= 0 ? railOneBalance : railTwoBalance, railToSystems[rail].length);
    }
    
    // Update universal flow state
    function _updateFlowState() internal {
        // Calculate flow velocity based on total flow and system activity
        uint256 totalActivity = 0;
        uint256 systemCount = 0;
        
        for (uint256 i = 1; i <= 3; i++) {
            address[] storage systems = railToSystems[i];
            for (uint256 j = 0; j < systems.length; j++) {
                totalActivity += systemFlowRate[systems[j]];
                systemCount++;
            }
        }
        
        if (systemCount > 0) {
            flowVelocity = (totalActivity * 1000000000000000000) / systemCount;
        }
        
        // Calculate flow pressure based on rail balance distribution
        uint256 totalRailBalance = railOneBalance + railTwoBalance + railThreeBalance;
        if (totalRailBalance > 0) {
            flowPressure = (railOneBalance * 1000000000000000000) / totalRailBalance;
        }
        
        // Calculate flow temperature based on flow velocity and pressure
        flowTemperature = (flowVelocity * flowPressure) / 1000000000000000000;
        
        emit FlowStateChanged(totalFlowState, flowVelocity, flowPressure, flowTemperature);
    }
    
    // Stabilize universal flow
    function stabilizeUniversalFlow() external onlyDeployer {
        // Calculate stabilization factor
        uint256 stabilizationFactor = _calculateStabilizationFactor();
        
        // Apply stabilization across rails
        _applyStabilization(stabilizationFactor);
        
        emit UniversalFlowStabilized(stabilizationFactor);
        _updateFlowState();
    }
    
    // Calculate stabilization factor
    function _calculateStabilizationFactor() internal view returns (uint256) {
        // Balance ideal ratio: 40% Rail One, 35% Rail Two, 25% Rail Three
        uint256 totalBalance = railOneBalance + railTwoBalance + railThreeBalance;
        
        if (totalBalance == 0) return 1000000000000000000; // 1.0 = no change needed
        
        uint256 railOneRatio = (railOneBalance * 1000000000000000000) / totalBalance;
        uint256 railTwoRatio = (railTwoBalance * 1000000000000000000) / totalBalance;
        uint256 railThreeRatio = (railThreeBalance * 1000000000000000000) / totalBalance;
        
        // Calculate deviation from ideal
        uint256 railOneDeviation = railOneRatio > 400000000000000000 ? railOneRatio - 400000000000000000 : 400000000000000000 - railOneRatio;
        uint256 railTwoDeviation = railTwoRatio > 350000000000000000 ? railTwoRatio - 350000000000000000 : 350000000000000000 - railTwoRatio;
        uint256 railThreeDeviation = railThreeRatio > 250000000000000000 ? railThreeRatio - 250000000000000000 : 250000000000000000 - railThreeRatio;
        
        uint256 totalDeviation = railOneDeviation + railTwoDeviation + railThreeDeviation;
        
        // Return stabilization factor (closer to 1.0 = more stable)
        return totalDeviation > 0 ? 1000000000000000000 - (totalDeviation / 3) : 1000000000000000000;
    }
    
    // Apply stabilization
    function _applyStabilization(uint256 stabilizationFactor) internal {
        // Move flows between rails to achieve ideal balance
        uint256 totalBalance = railOneBalance + railTwoBalance + railThreeBalance;
        
        if (totalBalance == 0) return;
        
        // Target balances
        uint256 targetRailOne = (totalBalance * 40) / 100;
        uint256 targetRailTwo = (totalBalance * 35) / 100;
        uint256 targetRailThree = (totalBalance * 25) / 100;
        
        // Calculate adjustments needed
        int256 railOneAdjustment = int256(targetRailOne) - int256(railOneBalance);
        int256 railTwoAdjustment = int256(targetRailTwo) - int256(railTwoBalance);
        int256 railThreeAdjustment = int256(targetRailThree) - int256(railThreeBalance);
        
        // Apply adjustments (in production, this would involve actual flow transfers)
        // For now, just update the balances
        if (railOneAdjustment != 0) {
            _updateRailBalance(RAIL_ONE, railOneAdjustment);
        }
        if (railTwoAdjustment != 0) {
            _updateRailBalance(RAIL_TWO, railTwoAdjustment);
        }
        if (railThreeAdjustment != 0) {
            _updateRailBalance(RAIL_THREE, railThreeAdjustment);
        }
    }
    
    // Get system flow balance
    function getSystemFlowBalance(address system) external view returns (uint256) {
        return systemFlowBalance[system];
    }
    
    // Get rail balances
    function getRailBalances() external view returns (
        uint256 railOne,
        uint256 railTwo,
        uint256 railThree,
        uint256 total
    ) {
        return (railOneBalance, railTwoBalance, railThreeBalance, railOneBalance + railTwoBalance + railThreeBalance);
    }
    
    // Get flow state
    function getFlowState() external view returns (
        uint256 totalFlow,
        uint256 velocity,
        uint256 pressure,
        uint256 temperature
    ) {
        return (totalFlowState, flowVelocity, flowPressure, flowTemperature);
    }
    
    // Get systems on rail
    function getSystemsOnRail(uint256 rail) external view returns (address[] memory) {
        return railToSystems[rail];
    }
    
    // Check if system is activated
    function isSystemActivated(address system) external view returns (bool) {
        return externalSystemWallets[system];
    }
    
    // Get system flow dynamics
    function getSystemFlowDynamics(address system) external view returns (
        uint256 balance,
        uint256 flowRate,
        uint256 capacity,
        uint256 resistance
    ) {
        return (
            systemFlowBalance[system],
            systemFlowRate[system],
            systemFlowCapacity[system],
            systemFlowResistance[system]
        );
    }
    
    // Update system flow resistance
    function updateSystemFlowResistance(address system, uint256 newResistance) external onlyDeployer {
        require(externalSystemWallets[system], "Invalid system");
        systemFlowResistance[system] = newResistance;
        _updateFlowState();
    }
    
    // Update system flow capacity
    function updateSystemFlowCapacity(address system, uint256 newCapacity) external onlyDeployer {
        require(externalSystemWallets[system], "Invalid system");
        systemFlowCapacity[system] = newCapacity;
        _updateFlowState();
    }
    
    // Move system between rails
    function moveSystemToRail(address system, uint256 newRail) external onlyDeployer {
        require(externalSystemWallets[system], "Invalid system");
        require(newRail >= RAIL_ONE && newRail <= RAIL_THREE, "Invalid rail");
        
        uint256 oldRail = systemRailAllocation[system];
        if (oldRail == newRail) return;
        
        // Remove from old rail
        address[] storage oldRailSystems = railToSystems[oldRail];
        for (uint256 i = 0; i < oldRailSystems.length; i++) {
            if (oldRailSystems[i] == system) {
                oldRailSystems[i] = oldRailSystems[oldRailSystems.length - 1];
                oldRailSystems.pop();
                break;
            }
        }
        
        // Add to new rail
        railToSystems[newRail].push(system);
        systemRailAllocation[system] = newRail;
        
        _updateFlowState();
    }
}
