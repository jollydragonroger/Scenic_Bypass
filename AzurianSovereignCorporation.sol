// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AzurianSovereignCorporation
 * @dev Complete governance and tribute system with child organizations
 * Implements 11% tribute model, bounty boards, and golden ratio governance
 */
contract AzurianSovereignCorporation is ERC20, Ownable, ReentrancyGuard {
    
    constructor() ERC20("AzurianSovereignCorporation", "AZURIAN") Ownable(msg.sender) {
        _initializeCapitalPools();
    }
    
    // Tribute allocation percentages (in basis points)
    uint256 public constant LOCAL_TRIBUTE = 1100;      // 11%
    uint256 public constant REGIONAL_TRIBUTE = 1100;   // 11%
    uint256 public constant GLOBAL_TRIBUTE = 1100;     // 11%
    uint256 public constant GOODS_ALLOCATION = 6600;  // 66%
    uint256 public constant LOTTERY_POOL = 100;       // 1%
    uint256 public constant EQUITY_REWARD = 1200;     // 12%
    uint256 public constant KINGDOM_TRIBUTE = 1500;   // 15% of each tribute (5% x 3)
    uint256 public constant PUBLIC_SERVICE_SURCHARGE = 330; // 3.3%
    
    // Golden ratio constants for governance
    uint256 public constant GOLDEN_RATIO = 1618033988749895; // φ * 10^15
    uint256 public constant GOLDEN_RATIO_TOLERANCE = 10000000000000; // 0.1% tolerance
    
    // Nine forms of capital
    enum CapitalForm {
        FINANCIAL,      // Money and investments
        MATERIAL,       // Physical assets and resources
        LIVING,         // Natural resources and ecosystems
        SOCIAL,         // Relationships and communities
        INTELLECTUAL,   // Knowledge and intellectual property
        EXPERIENTIAL,   // Skills and experiences
        SPIRITUAL,      // Faith, values, and meaning
        CULTURAL,       // Arts, traditions, and heritage
        POLITICAL       // Power, influence, and organization
    }
    
    // Organization types
    enum OrganizationType {
        INDIVIDUAL,
        INSTITUTION,
        GOVERNMENT,
        CHURCH,
        CORPORATION,
        NONPROFIT,
        COOPERATIVE,
        MINISTRY,
        PRIVATEER,
        SOVEREIGN_NATION
    }
    
    // Bounty types
    enum BountyType {
        WHITE_HAT,    // Constructive, build something
        BLACK_HAT,    // Justice, find truth, poetic justice
        CLEAR_HAT,    // Neutral, maintenance
        PIRATE        // Security testing, vulnerability discovery
    }
    
    struct ChildOrganization {
        address owner;
        OrganizationType orgType;
        string name;
        string jurisdiction;
        uint256 registrationTime;
        bool isActive;
        uint256 governancePower;
        mapping(address => bool) members;
        uint256 memberCount;
        uint256 groupAllocationPower; // 1/3 of total can be group-controlled
    }
    
    struct TributeAllocation {
        uint256 localPercentage;      // User controls 2/3, group controls 1/3
        uint256 regionalPercentage;   // User controls 2/3, group controls 1/3
        uint256 globalPercentage;     // User controls 2/3, group controls 1/3
        uint256 lastUpdateTime;
        bool isLocked;
    }
    
    struct Bounty {
        bytes32 bountyId;
        address poster;
        BountyType bountyType;
        CapitalForm capitalForm;
        string description;
        uint256 rewardAmount;
        uint256 starRating; // 1-5 stars difficulty rating
        uint256 deadline;
        bool isActive;
        address[] claimants;
        mapping(address => bool) hasClaimed;
        uint256 requiredStars;
    }
    
    struct TransactionRecord {
        address user;
        uint256 amount;
        uint256 timestamp;
        uint256 blockNumber;
        bytes32 transactionHash;
        bool wonLottery;
        uint256 lotteryAmount;
        address childOrganization;
    }
    
    // Storage mappings
    mapping(address => ChildOrganization) public childOrganizations;
    mapping(address => TributeAllocation) public tributeAllocations;
    mapping(bytes32 => Bounty) public bounties;
    mapping(address => TransactionRecord[]) public userTransactions;
    mapping(uint256 => address) public lotteryWinners; // block number => winner
    mapping(CapitalForm => uint256) public capitalPools;
    
    // Tribute pools
    uint256 public localTributePool;
    uint256 public regionalTributePool;
    uint256 public globalTributePool;
    uint256 public lotteryPool;
    uint256 public publicServicePool;
    uint256 public kingdomTributePool;
    
    // Governance state
    uint256 public currentGoldenRatio;
    uint256 public governanceAlignment;
    address public sicilianCrownTreasury;
    address public newCaliforniaRepublicTreasury;
    address public ascwTreasury;
    address public acotoAllianceTreasury;
    
    // Arrays for enumeration
    address[] public childOrganizationAddresses;
    bytes32[] public activeBounties;
    
    // Events
    event ChildOrganizationRegistered(address indexed orgAddress, string name, OrganizationType orgType);
    event TributeDistributed(address indexed user, uint256 local, uint256 regional, uint256 global);
    event BountyPosted(bytes32 indexed bountyId, address indexed poster, BountyType bountyType, uint256 reward);
    event BountyClaimed(bytes32 indexed bountyId, address indexed claimant, uint256 reward);
    event LotteryWon(address indexed winner, uint256 amount, uint256 blockNumber);
    event GoldenRatioAligned(uint256 currentRatio, uint256 targetRatio);
    event PublicServicePaid(address indexed recipient, uint256 amount);
    event KingdomTributeCollected(uint256 amount, string jurisdiction);
    
    function _initializeCapitalPools() internal {
        currentGoldenRatio = GOLDEN_RATIO;
        governanceAlignment = 10000; // 100% alignment
        
        // Initialize capital pools
        for (uint256 i = 0; i < 9; i++) {
            capitalPools[CapitalForm(i)] = 0;
        }
    }
    
    /**
     * @dev Register as a child organization to participate in governance
     */
    function registerChildOrganization(
        string memory _name,
        OrganizationType _orgType,
        string memory _jurisdiction
    ) external returns (address) {
        require(childOrganizations[msg.sender].owner == address(0), "Already registered");
        require(bytes(_name).length > 0, "Name required");
        require(bytes(_jurisdiction).length > 0, "Jurisdiction required");
        
        // Create new child organization
        ChildOrganization storage org = childOrganizations[msg.sender];
        org.owner = msg.sender;
        org.orgType = _orgType;
        org.name = _name;
        org.jurisdiction = _jurisdiction;
        org.registrationTime = block.timestamp;
        org.isActive = true;
        org.governancePower = 1000; // Base governance power
        org.groupAllocationPower = 333; // 1/3 of 1000
        
        // Add to members
        org.members[msg.sender] = true;
        org.memberCount = 1;
        
        // Initialize tribute allocation (user controls 2/3, group controls 1/3)
        TributeAllocation storage allocation = tributeAllocations[msg.sender];
        allocation.localPercentage = 667; // 2/3 to user
        allocation.regionalPercentage = 667;
        allocation.globalPercentage = 667;
        allocation.lastUpdateTime = block.timestamp;
        allocation.isLocked = false;
        
        childOrganizationAddresses.push(msg.sender);
        
        emit ChildOrganizationRegistered(msg.sender, _name, _orgType);
        
        return msg.sender;
    }
    
    /**
     * @dev Add member to child organization
     */
    function addMemberToOrganization(address _member) external {
        require(childOrganizations[msg.sender].owner != address(0), "Not registered");
        require(childOrganizations[msg.sender].owner == msg.sender, "Not organization owner");
        require(!childOrganizations[msg.sender].members[_member], "Already member");
        
        ChildOrganization storage org = childOrganizations[msg.sender];
        org.members[_member] = true;
        org.memberCount++;
        org.governancePower += 1000;
        org.groupAllocationPower += 333;
    }
    
    /**
     * @dev Execute transaction with tribute distribution
     */
    function executeTransaction(
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) external nonReentrant returns (bool) {
        require(_amount > 0, "Amount must be > 0");
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        
        // Calculate tribute distributions
        uint256 localTribute = (_amount * LOCAL_TRIBUTE) / 10000;
        uint256 regionalTribute = (_amount * REGIONAL_TRIBUTE) / 10000;
        uint256 globalTribute = (_amount * GLOBAL_TRIBUTE) / 10000;
        uint256 goodsAllocation = (_amount * GOODS_ALLOCATION) / 10000;
        uint256 lotteryContribution = (_amount * LOTTERY_POOL) / 10000;
        uint256 equityReward = (_amount * EQUITY_REWARD) / 10000;
        uint256 publicServiceContribution = (_amount * PUBLIC_SERVICE_SURCHARGE) / 10000;
        
        // Total tribute taken
        uint256 totalTribute = localTribute + regionalTribute + globalTribute
                                + lotteryContribution + equityReward
                                + publicServiceContribution;
        
        // Check if user is part of child organization
        address childOrg = address(0);
        if (childOrganizations[msg.sender].owner != address(0)) {
            childOrg = msg.sender;
        }
        
        // Transfer tokens
        _transfer(msg.sender, _to, _amount - totalTribute);
        
        // Distribute tributes
        _distributeTributes(msg.sender, localTribute, regionalTribute, globalTribute, childOrg);
        
        // Add to lottery pool
        lotteryPool = lotteryPool + lotteryContribution;
        
        // Mint equity reward to user
        _mint(msg.sender, equityReward);
        
        // Add to public service pool
        publicServicePool = publicServicePool + publicServiceContribution;
        
        // Record transaction
        _recordTransaction(msg.sender, _amount, childOrg);
        
        // Check lottery winner
        _checkLotteryWinner(msg.sender, block.number);
        
        // Update golden ratio alignment
        _updateGoldenRatioAlignment();
        
        emit TributeDistributed(msg.sender, localTribute, regionalTribute, globalTribute);
        
        return true;
    }
    
    /**
     * @dev Distribute tributes to respective pools
     */
    function _distributeTributes(
        address _user,
        uint256 _localTribute,
        uint256 _regionalTribute,
        uint256 _globalTribute,
        address _childOrg
    ) internal {
        // Add to tribute pools
        localTributePool = localTributePool + _localTribute;
        regionalTributePool = regionalTributePool + _regionalTribute;
        globalTributePool = globalTributePool + _globalTribute;
        
        // Calculate kingdom tribute (5% of each tribute)
        uint256 kingdomLocal = (_localTribute * 500) / 10000;
        uint256 kingdomRegional = (_regionalTribute * 500) / 10000;
        uint256 kingdomGlobal = (_globalTribute * 500) / 10000;
        
        uint256 totalKingdomTribute = kingdomLocal + kingdomRegional + kingdomGlobal;
        kingdomTributePool = kingdomTributePool + totalKingdomTribute;
        
        // Get jurisdiction for local tribute allocation
        string memory jurisdiction = "global";
        if (_childOrg != address(0)) {
            jurisdiction = childOrganizations[_childOrg].jurisdiction;
        }
        
        emit KingdomTributeCollected(totalKingdomTribute, jurisdiction);
    }
    
    /**
     * @dev Record transaction for lottery eligibility
     */
    function _recordTransaction(address _user, uint256 _amount, address _childOrg) internal {
        TransactionRecord memory record = TransactionRecord({
            user: _user,
            amount: _amount,
            timestamp: block.timestamp,
            blockNumber: block.number,
            transactionHash: keccak256(abi.encodePacked(_user, _amount, block.timestamp)),
            wonLottery: false,
            lotteryAmount: 0,
            childOrganization: _childOrg
        });
        
        userTransactions[_user].push(record);
    }
    
    /**
     * @dev Check if user wins lottery for current block
     */
    function _checkLotteryWinner(address _user, uint256 _blockNumber) internal {
        // Simple lottery based on block hash and user address
        bytes32 hash = blockhash(_blockNumber);
        uint256 random = uint256(hash) >> 128; // Take first 128 bits
        
        // 1 in 1000 chance of winning
        if (random % 1000 == 0) {
            uint256 lotteryAmount = lotteryPool / 10; // Win 10% of pool
            if (lotteryAmount > 0) {
                _transfer(address(this), _user, lotteryAmount);
                lotteryPool = lotteryPool - lotteryAmount;
                
                // Update transaction record
                if (userTransactions[_user].length > 0) {
                    userTransactions[_user][userTransactions[_user].length - 1].wonLottery = true;
                    userTransactions[_user][userTransactions[_user].length - 1].lotteryAmount = lotteryAmount;
                }
                
                lotteryWinners[_blockNumber] = _user;
                
                emit LotteryWon(_user, lotteryAmount, _blockNumber);
            }
        }
    }
    
    /**
     * @dev Post a bounty for public service
     */
    function postBounty(
        BountyType _bountyType,
        CapitalForm _capitalForm,
        string memory _description,
        uint256 _rewardAmount,
        uint256 _starRating,
        uint256 _deadline
    ) external returns (bytes32) {
        require(_rewardAmount > 0, "Reward must be > 0");
        require(_starRating >= 1 && _starRating <= 5, "Invalid star rating");
        require(_deadline > block.timestamp, "Invalid deadline");
        
        bytes32 bountyId = keccak256(abi.encodePacked(
            msg.sender, _bountyType, _capitalForm, _description, block.timestamp
        ));
        
        Bounty storage bounty = bounties[bountyId];
        bounty.bountyId = bountyId;
        bounty.poster = msg.sender;
        bounty.bountyType = _bountyType;
        bounty.capitalForm = _capitalForm;
        bounty.description = _description;
        bounty.rewardAmount = _rewardAmount;
        bounty.starRating = _starRating;
        bounty.deadline = _deadline;
        bounty.isActive = true;
        bounty.requiredStars = _starRating;
        
        // Transfer reward to bounty contract
        _transfer(msg.sender, address(this), _rewardAmount);
        
        activeBounties.push(bountyId);
        
        emit BountyPosted(bountyId, msg.sender, _bountyType, _rewardAmount);
        
        return bountyId;
    }
    
    /**
     * @dev Claim a bounty with proof of work
     */
    function claimBounty(
        bytes32 _bountyId,
        string memory _proofOfWork,
        string memory _patchProof
    ) external nonReentrant {
        Bounty storage bounty = bounties[_bountyId];
        require(bounty.isActive, "Bounty not active");
        require(!bounty.hasClaimed[msg.sender], "Already claimed");
        require(block.timestamp <= bounty.deadline, "Bounty expired");
        
        // For pirate bounties, require patch proof
        if (bounty.bountyType == BountyType.PIRATE) {
            require(bytes(_patchProof).length > 0, "Patch proof required");
        }
        
        // Mark as claimed
        bounty.hasClaimed[msg.sender] = true;
        bounty.claimants.push(msg.sender);
        
        // Transfer reward
        _transfer(address(this), msg.sender, bounty.rewardAmount);
        
        // Pay public service surcharge (3.3% of bounty)
        uint256 publicServicePayment = (bounty.rewardAmount * PUBLIC_SERVICE_SURCHARGE) / 10000;
        if (publicServicePayment > 0 && publicServicePool >= publicServicePayment) {
            publicServicePool = publicServicePool - publicServicePayment;
            _transfer(address(this), msg.sender, publicServicePayment);
            
            emit PublicServicePaid(msg.sender, publicServicePayment);
        }
        
        emit BountyClaimed(_bountyId, msg.sender, bounty.rewardAmount);
    }
    
    /**
     * @dev Update tribute allocation (user controls 2/3 minimum)
     */
    function updateTributeAllocation(
        uint256 _localPercentage,
        uint256 _regionalPercentage,
        uint256 _globalPercentage
    ) external {
        require(childOrganizations[msg.sender].owner != address(0), "Not registered");
        
        TributeAllocation storage allocation = tributeAllocations[msg.sender];
        require(!allocation.isLocked, "Allocation locked");
        
        // User must control at least 2/3 (667 basis points)
        require(_localPercentage >= 667, "Local allocation too low");
        require(_regionalPercentage >= 667, "Regional allocation too low");
        require(_globalPercentage >= 667, "Global allocation too low");
        
        allocation.localPercentage = _localPercentage;
        allocation.regionalPercentage = _regionalPercentage;
        allocation.globalPercentage = _globalPercentage;
        allocation.lastUpdateTime = block.timestamp;
    }
    
    /**
     * @dev Update golden ratio alignment for governance
     */
    function _updateGoldenRatioAlignment() internal {
        // Calculate current system golden ratio based on various metrics
        uint256 totalSupply = totalSupply();
        uint256 totalValue = localTributePool + regionalTributePool + globalTributePool;
        
        if (totalValue > 0) {
            currentGoldenRatio = (totalSupply * 1000000) / totalValue;
            
            // Calculate alignment with target golden ratio
            uint256 difference = currentGoldenRatio > GOLDEN_RATIO ? 
                currentGoldenRatio - GOLDEN_RATIO : GOLDEN_RATIO - currentGoldenRatio;
            
            if (difference <= GOLDEN_RATIO_TOLERANCE) {
                governanceAlignment = 10000; // 100% aligned
            } else {
                governanceAlignment = 10000 - (difference * 10000) / GOLDEN_RATIO;
            }
            
            emit GoldenRatioAligned(currentGoldenRatio, GOLDEN_RATIO);
        }
    }
    
    /**
     * @dev Get user's transaction history
     */
    function getUserTransactions(address _user) external view returns (TransactionRecord[] memory) {
        return userTransactions[_user];
    }
    
    /**
     * @dev Get active bounties
     */
    function getActiveBounties() external view returns (bytes32[] memory) {
        return activeBounties;
    }
    
    /**
     * @dev Get child organization info
     */
    function getChildOrganization(address _orgAddress) external view returns (
        address owner,
        OrganizationType orgType,
        string memory name,
        string memory jurisdiction,
        uint256 registrationTime,
        bool isActive,
        uint256 governancePower,
        uint256 memberCount,
        uint256 groupAllocationPower
    ) {
        ChildOrganization storage org = childOrganizations[_orgAddress];
        return (
            org.owner,
            org.orgType,
            org.name,
            org.jurisdiction,
            org.registrationTime,
            org.isActive,
            org.governancePower,
            org.memberCount,
            org.groupAllocationPower
        );
    }
    
    /**
     * @dev Collect kingdom tribute for Sicilian Crown
     */
    function collectKingdomTribute() external onlyOwner {
        uint256 amount = kingdomTributePool;
        if (amount > 0) {
            kingdomTributePool = 0;
            _transfer(address(this), sicilianCrownTreasury, amount);
        }
    }
    
    /**
     * @dev Pay public service administrators
     */
    function payPublicService(address _recipient, uint256 _amount) external onlyOwner {
        require(_amount <= publicServicePool, "Insufficient public service funds");
        publicServicePool = publicServicePool - _amount;
        _transfer(address(this), _recipient, _amount);
        
        emit PublicServicePaid(_recipient, _amount);
    }
}
