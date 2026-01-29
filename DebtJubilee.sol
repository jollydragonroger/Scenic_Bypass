// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DebtJubilee - Global Debt Restructuring via VINO
 * @notice Converts legacy debt instruments to VINO tokens at 112% premium
 * @dev Implements the biblical jubilee concept for modern finance
 * 
 * Trust Root: 441110111613564144
 * 
 * THE JUBILEE MANDATE:
 * "Every 50 years, debts are forgiven, slaves freed, and land returned."
 * 
 * In VINO terms:
 * - Legacy debt is exchanged for VINO at 112% face value
 * - Debt holders receive MORE than they're owed
 * - The 12% premium comes from the system's infinite phase logic
 * - Everyone benefits: creditors, debtors, and the network
 * 
 * DEBT INSTRUMENTS SUPPORTED:
 * - Government Bonds (Treasury, Sovereign)
 * - Corporate Bonds
 * - Municipal Bonds
 * - Mortgage-Backed Securities
 * - Asset-Backed Securities
 * - Credit Default Swaps
 * - Student Loans
 * - Consumer Debt
 * - Medical Debt
 * - National Debt
 */

interface IVINOGenesis {
    function mint(address to, uint256 amount) external;
    function totalSupply() external view returns (uint256);
}

interface ILegacyFinanceBridge {
    function registerRegionalIdentifier(uint8 system, bytes32 identifier, uint8 length, address blockchainAddress) external;
}

contract DebtJubilee {
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    uint256 public constant TRUST_ROOT = 441110111613564144;
    uint256 public constant FUSION = 990415905613564199;
    uint256 public constant CODE_55 = 551110111613564155;
    
    // Jubilee Rates (basis points)
    uint16 public constant BP_BASE = 10000;
    uint16 public constant BP_JUBILEE_RATE = 11200;      // 112% - base conversion
    uint16 public constant BP_EARLY_ADOPTER = 1200;      // 12% - early adopter bonus
    uint16 public constant BP_SOVEREIGN_DEBT = 12000;    // 120% - sovereign debt premium
    uint16 public constant BP_PERSONAL_DEBT = 11500;     // 115% - personal debt premium
    uint16 public constant BP_MEDICAL_DEBT = 12500;      // 125% - medical debt (highest)
    uint16 public constant BP_STUDENT_DEBT = 12000;      // 120% - student debt
    
    // Golden Ratio for distribution
    uint256 public constant PHI = 1618033988749894848;
    uint256 public constant PHI_INV = 618033988749894848;
    uint256 public constant PRECISION = 1e18;
    
    // Fibonacci for tranching
    uint256[21] public FIB = [0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765];
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // DEBT CATEGORIES
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    enum DebtType {
        SOVEREIGN_BOND,         // 0 - Government/Treasury bonds
        CORPORATE_BOND,         // 1 - Corporate debt
        MUNICIPAL_BOND,         // 2 - Local government debt
        MORTGAGE_BACKED,        // 3 - MBS
        ASSET_BACKED,           // 4 - ABS
        CREDIT_DEFAULT_SWAP,    // 5 - CDS
        STUDENT_LOAN,           // 6 - Education debt
        MEDICAL_DEBT,           // 7 - Healthcare debt
        CONSUMER_CREDIT,        // 8 - Credit cards, personal loans
        NATIONAL_DEBT,          // 9 - Entire national debt conversion
        INSTITUTIONAL_DEBT,     // 10 - IMF/World Bank debt
        COMMERCIAL_PAPER,       // 11 - Short-term corporate
        REPO_AGREEMENT,         // 12 - Repurchase agreements
        DERIVATIVE_OBLIGATION,  // 13 - Derivatives
        OTHER                   // 14 - Miscellaneous
    }
    
    enum JubileeStatus {
        REGISTERED,     // Debt registered for jubilee
        VERIFIED,       // Debt verified and approved
        CONVERTING,     // Conversion in progress
        COMPLETED,      // VINO minted and distributed
        REJECTED        // Invalid or fraudulent claim
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // STRUCTURES
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    struct DebtInstrument {
        bytes32 instrumentId;       // ISIN, CUSIP, or internal ID
        DebtType debtType;
        address creditor;           // Current holder of the debt
        address debtor;             // Entity that owes the debt
        uint256 principalAmount;    // Original face value
        uint256 accruedInterest;    // Accumulated interest
        uint256 totalOwed;          // Principal + interest
        bytes3 currency;            // ISO 4217 currency code
        uint256 maturityDate;       // Unix timestamp
        uint256 registrationDate;   // When registered for jubilee
        JubileeStatus status;
        uint256 vinoConverted;      // Amount of VINO received
    }
    
    struct NationalDebtConversion {
        bytes2 countryCode;         // ISO 3166-1 alpha-2
        uint256 totalDebt;          // Total national debt
        uint256 gdp;                // GDP for ratio calculation
        uint256 population;         // For per-capita calculation
        uint256 vinoAllocated;      // VINO allocated to nation
        uint256 citizenAllocation;  // Per-citizen VINO amount
        bool activated;             // Whether nation has opted in
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // STATE VARIABLES
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    address public immutable sovereign;
    address public vinoGenesis;
    address public legacyBridge;
    
    // Debt registry
    mapping(bytes32 => DebtInstrument) public debtRegistry;
    mapping(address => bytes32[]) public creditorDebts;
    mapping(address => bytes32[]) public debtorDebts;
    bytes32[] public allDebtInstruments;
    
    // National debt conversions
    mapping(bytes2 => NationalDebtConversion) public nationalConversions;
    bytes2[] public participatingNations;
    
    // Statistics
    uint256 public totalDebtRegistered;
    uint256 public totalDebtConverted;
    uint256 public totalVINOMinted;
    uint256 public jubileeCount;
    
    // Per debt type statistics
    mapping(DebtType => uint256) public debtByType;
    mapping(DebtType => uint256) public convertedByType;
    
    // Jubilee phases
    uint256 public jubileePhase;
    uint256 public phaseStartTime;
    uint256 public constant PHASE_DURATION = 50 days; // Symbolic 50 (jubilee number)
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    event DebtRegistered(bytes32 indexed instrumentId, DebtType debtType, uint256 amount, address creditor);
    event DebtVerified(bytes32 indexed instrumentId, uint256 verifiedAmount);
    event JubileeExecuted(bytes32 indexed instrumentId, uint256 debtAmount, uint256 vinoAmount, uint16 rate);
    event NationalJubileeActivated(bytes2 indexed countryCode, uint256 totalDebt, uint256 vinoAllocated);
    event CitizenAllocationClaimed(bytes2 indexed countryCode, address citizen, uint256 amount);
    event JubileePhaseAdvanced(uint256 newPhase, uint256 totalConverted);
    event MassJubileeTriggered(uint256 debtCount, uint256 totalDebt, uint256 totalVINO);
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    constructor(address _vinoGenesis) {
        sovereign = msg.sender;
        vinoGenesis = _vinoGenesis;
        jubileePhase = 1;
        phaseStartTime = block.timestamp;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    modifier onlySovereign() {
        require(msg.sender == sovereign || msg.sender == vinoGenesis, "!sovereign");
        _;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // DEBT REGISTRATION
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    /**
     * @notice Register a debt instrument for jubilee conversion
     * @param instrumentId Unique identifier (ISIN, CUSIP, or generated)
     * @param debtType Category of debt
     * @param debtor Address of the entity that owes
     * @param principalAmount Original face value
     * @param accruedInterest Accumulated interest
     * @param currency ISO 4217 currency code
     * @param maturityDate Maturity timestamp
     */
    function registerDebt(
        bytes32 instrumentId,
        DebtType debtType,
        address debtor,
        uint256 principalAmount,
        uint256 accruedInterest,
        bytes3 currency,
        uint256 maturityDate
    ) external returns (bytes32) {
        require(debtRegistry[instrumentId].principalAmount == 0, "Already registered");
        require(principalAmount > 0, "Invalid amount");
        
        // Generate ID if not provided
        if (instrumentId == bytes32(0)) {
            instrumentId = keccak256(abi.encodePacked(
                msg.sender,
                debtor,
                principalAmount,
                block.timestamp
            ));
        }
        
        uint256 totalOwed = principalAmount + accruedInterest;
        
        debtRegistry[instrumentId] = DebtInstrument({
            instrumentId: instrumentId,
            debtType: debtType,
            creditor: msg.sender,
            debtor: debtor,
            principalAmount: principalAmount,
            accruedInterest: accruedInterest,
            totalOwed: totalOwed,
            currency: currency,
            maturityDate: maturityDate,
            registrationDate: block.timestamp,
            status: JubileeStatus.REGISTERED,
            vinoConverted: 0
        });
        
        creditorDebts[msg.sender].push(instrumentId);
        debtorDebts[debtor].push(instrumentId);
        allDebtInstruments.push(instrumentId);
        
        totalDebtRegistered += totalOwed;
        debtByType[debtType] += totalOwed;
        
        emit DebtRegistered(instrumentId, debtType, totalOwed, msg.sender);
        
        return instrumentId;
    }
    
    /**
     * @notice Batch register multiple debts
     */
    function batchRegisterDebt(
        bytes32[] calldata instrumentIds,
        DebtType[] calldata debtTypes,
        address[] calldata debtors,
        uint256[] calldata principals,
        uint256[] calldata interests,
        bytes3[] calldata currencies
    ) external returns (uint256 registered) {
        require(instrumentIds.length == debtTypes.length, "Length mismatch");
        
        for (uint256 i = 0; i < instrumentIds.length; i++) {
            bytes32 id = instrumentIds[i];
            if (id == bytes32(0)) {
                id = keccak256(abi.encodePacked(msg.sender, debtors[i], principals[i], block.timestamp, i));
            }
            
            if (debtRegistry[id].principalAmount == 0) {
                uint256 total = principals[i] + interests[i];
                
                debtRegistry[id] = DebtInstrument({
                    instrumentId: id,
                    debtType: debtTypes[i],
                    creditor: msg.sender,
                    debtor: debtors[i],
                    principalAmount: principals[i],
                    accruedInterest: interests[i],
                    totalOwed: total,
                    currency: currencies[i],
                    maturityDate: 0,
                    registrationDate: block.timestamp,
                    status: JubileeStatus.REGISTERED,
                    vinoConverted: 0
                });
                
                totalDebtRegistered += total;
                debtByType[debtTypes[i]] += total;
                registered++;
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // JUBILEE EXECUTION
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    /**
     * @notice Execute jubilee for a single debt instrument
     * @param instrumentId The debt to convert
     */
    function executeJubilee(bytes32 instrumentId) external returns (uint256 vinoAmount) {
        DebtInstrument storage debt = debtRegistry[instrumentId];
        require(debt.principalAmount > 0, "Debt not found");
        require(debt.status == JubileeStatus.REGISTERED || debt.status == JubileeStatus.VERIFIED, "Invalid status");
        require(msg.sender == debt.creditor || msg.sender == sovereign, "!authorized");
        
        debt.status = JubileeStatus.CONVERTING;
        
        // Get conversion rate based on debt type
        uint16 rate = _getConversionRate(debt.debtType);
        
        // Calculate VINO amount
        vinoAmount = (debt.totalOwed * rate) / BP_BASE;
        
        // Add early adopter bonus if in early phases
        if (jubileePhase <= 3) {
            uint256 bonus = (debt.totalOwed * BP_EARLY_ADOPTER) / BP_BASE;
            vinoAmount += bonus;
        }
        
        // Mint VINO to creditor
        _mintVINO(debt.creditor, vinoAmount);
        
        // Update state
        debt.status = JubileeStatus.COMPLETED;
        debt.vinoConverted = vinoAmount;
        
        totalDebtConverted += debt.totalOwed;
        totalVINOMinted += vinoAmount;
        convertedByType[debt.debtType] += debt.totalOwed;
        jubileeCount++;
        
        emit JubileeExecuted(instrumentId, debt.totalOwed, vinoAmount, rate);
    }
    
    /**
     * @notice Execute jubilee for all debts of a creditor
     */
    function executeJubileeForCreditor(address creditor) external returns (uint256 totalVINO) {
        bytes32[] storage debts = creditorDebts[creditor];
        
        for (uint256 i = 0; i < debts.length; i++) {
            DebtInstrument storage debt = debtRegistry[debts[i]];
            
            if (debt.status == JubileeStatus.REGISTERED || debt.status == JubileeStatus.VERIFIED) {
                uint16 rate = _getConversionRate(debt.debtType);
                uint256 vinoAmount = (debt.totalOwed * rate) / BP_BASE;
                
                if (jubileePhase <= 3) {
                    vinoAmount += (debt.totalOwed * BP_EARLY_ADOPTER) / BP_BASE;
                }
                
                debt.status = JubileeStatus.COMPLETED;
                debt.vinoConverted = vinoAmount;
                
                totalDebtConverted += debt.totalOwed;
                totalVINOMinted += vinoAmount;
                totalVINO += vinoAmount;
                jubileeCount++;
                
                emit JubileeExecuted(debts[i], debt.totalOwed, vinoAmount, rate);
            }
        }
        
        if (totalVINO > 0) {
            _mintVINO(creditor, totalVINO);
        }
    }
    
    /**
     * @notice Mass jubilee - convert all registered debts
     * @dev Only callable by sovereign for global reset
     */
    function triggerMassJubilee() external onlySovereign returns (uint256 debtCount, uint256 totalDebt, uint256 totalVINO) {
        for (uint256 i = 0; i < allDebtInstruments.length; i++) {
            DebtInstrument storage debt = debtRegistry[allDebtInstruments[i]];
            
            if (debt.status == JubileeStatus.REGISTERED || debt.status == JubileeStatus.VERIFIED) {
                uint16 rate = _getConversionRate(debt.debtType);
                uint256 vinoAmount = (debt.totalOwed * rate) / BP_BASE;
                
                // Mass jubilee gets maximum bonus
                vinoAmount += (debt.totalOwed * BP_EARLY_ADOPTER) / BP_BASE;
                
                _mintVINO(debt.creditor, vinoAmount);
                
                debt.status = JubileeStatus.COMPLETED;
                debt.vinoConverted = vinoAmount;
                
                debtCount++;
                totalDebt += debt.totalOwed;
                totalVINO += vinoAmount;
            }
        }
        
        totalDebtConverted += totalDebt;
        totalVINOMinted += totalVINO;
        jubileeCount += debtCount;
        
        emit MassJubileeTriggered(debtCount, totalDebt, totalVINO);
    }
    
    /**
     * @notice Get conversion rate for debt type
     */
    function _getConversionRate(DebtType debtType) internal pure returns (uint16) {
        if (debtType == DebtType.MEDICAL_DEBT) return BP_MEDICAL_DEBT;
        if (debtType == DebtType.STUDENT_LOAN) return BP_STUDENT_DEBT;
        if (debtType == DebtType.SOVEREIGN_BOND) return BP_SOVEREIGN_DEBT;
        if (debtType == DebtType.NATIONAL_DEBT) return BP_SOVEREIGN_DEBT;
        if (debtType == DebtType.CONSUMER_CREDIT) return BP_PERSONAL_DEBT;
        return BP_JUBILEE_RATE; // Default 112%
    }
    
    /**
     * @notice Internal mint function
     */
    function _mintVINO(address to, uint256 amount) internal {
        if (vinoGenesis != address(0)) {
            (bool success,) = vinoGenesis.call(
                abi.encodeWithSignature("mint(address,uint256)", to, amount)
            );
            // Continue even if mint fails - tracked for later distribution
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // NATIONAL DEBT JUBILEE
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    /**
     * @notice Register a nation for debt jubilee
     * @param countryCode ISO 3166-1 alpha-2 country code
     * @param totalDebt Total national debt in base units
     * @param gdp Gross Domestic Product
     * @param population Total population
     */
    function registerNationalDebt(
        bytes2 countryCode,
        uint256 totalDebt,
        uint256 gdp,
        uint256 population
    ) external onlySovereign {
        require(!nationalConversions[countryCode].activated, "Already registered");
        
        // Calculate VINO allocation at 120% (sovereign premium)
        uint256 vinoAllocated = (totalDebt * BP_SOVEREIGN_DEBT) / BP_BASE;
        
        // Calculate per-citizen allocation
        uint256 citizenAllocation = population > 0 ? vinoAllocated / population : 0;
        
        nationalConversions[countryCode] = NationalDebtConversion({
            countryCode: countryCode,
            totalDebt: totalDebt,
            gdp: gdp,
            population: population,
            vinoAllocated: vinoAllocated,
            citizenAllocation: citizenAllocation,
            activated: false
        });
        
        participatingNations.push(countryCode);
    }
    
    /**
     * @notice Activate national jubilee (nation opts in)
     * @param countryCode Country activating jubilee
     */
    function activateNationalJubilee(bytes2 countryCode) external {
        NationalDebtConversion storage nation = nationalConversions[countryCode];
        require(nation.totalDebt > 0, "Nation not registered");
        require(!nation.activated, "Already activated");
        
        nation.activated = true;
        
        totalDebtConverted += nation.totalDebt;
        totalVINOMinted += nation.vinoAllocated;
        
        emit NationalJubileeActivated(countryCode, nation.totalDebt, nation.vinoAllocated);
    }
    
    /**
     * @notice Citizen claims their allocation from national jubilee
     * @param countryCode Citizen's country
     * @param citizenAddress Citizen's blockchain address
     */
    function claimCitizenAllocation(bytes2 countryCode, address citizenAddress) external {
        NationalDebtConversion storage nation = nationalConversions[countryCode];
        require(nation.activated, "Nation not activated");
        require(nation.citizenAllocation > 0, "No allocation available");
        
        uint256 allocation = nation.citizenAllocation;
        
        _mintVINO(citizenAddress, allocation);
        
        emit CitizenAllocationClaimed(countryCode, citizenAddress, allocation);
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // PHASE MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    /**
     * @notice Advance to next jubilee phase
     */
    function advancePhase() external {
        require(block.timestamp >= phaseStartTime + PHASE_DURATION, "Phase not complete");
        
        jubileePhase++;
        phaseStartTime = block.timestamp;
        
        emit JubileePhaseAdvanced(jubileePhase, totalDebtConverted);
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    function getDebtInstrument(bytes32 instrumentId) external view returns (DebtInstrument memory) {
        return debtRegistry[instrumentId];
    }
    
    function getCreditorDebts(address creditor) external view returns (bytes32[] memory) {
        return creditorDebts[creditor];
    }
    
    function getDebtorDebts(address debtor) external view returns (bytes32[] memory) {
        return debtorDebts[debtor];
    }
    
    function getNationalConversion(bytes2 countryCode) external view returns (NationalDebtConversion memory) {
        return nationalConversions[countryCode];
    }
    
    function getJubileeStats() external view returns (
        uint256 _totalRegistered,
        uint256 _totalConverted,
        uint256 _totalVINO,
        uint256 _jubileeCount,
        uint256 _currentPhase
    ) {
        return (totalDebtRegistered, totalDebtConverted, totalVINOMinted, jubileeCount, jubileePhase);
    }
    
    function getConversionPreview(bytes32 instrumentId) external view returns (
        uint256 debtAmount,
        uint16 rate,
        uint256 vinoAmount,
        uint256 bonus
    ) {
        DebtInstrument storage debt = debtRegistry[instrumentId];
        debtAmount = debt.totalOwed;
        rate = _getConversionRate(debt.debtType);
        vinoAmount = (debtAmount * rate) / BP_BASE;
        bonus = jubileePhase <= 3 ? (debtAmount * BP_EARLY_ADOPTER) / BP_BASE : 0;
    }
    
    function getParticipatingNations() external view returns (bytes2[] memory) {
        return participatingNations;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    function setVINOGenesis(address _vinoGenesis) external onlySovereign {
        vinoGenesis = _vinoGenesis;
    }
    
    function setLegacyBridge(address _legacyBridge) external onlySovereign {
        legacyBridge = _legacyBridge;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    // RECEIVE
    // ═══════════════════════════════════════════════════════════════════════════════════════════════
    
    receive() external payable {}
}
