// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title FreedomEconomics
 * @dev Economic incentives for liberty defense and information freedom
 */
contract FreedomEconomics {
    // Economic state
    uint256 public totalLibertyRewards;
    mapping(address => uint256) public userRewards;
    mapping(address => uint256) public suppressionBounties;
    
    // Token economics
    mapping(address => uint256) public freedomTokenBalance;
    uint256 public freedomTokenSupply;
    
    // Profit sharing
    mapping(address => uint256) public profitShares;
    uint256 public totalProfitPool;
    
    // Liberty activities
    mapping(address => uint256) public libertyActivities;
    mapping(address => bool) public verifiedFreedomDefenders;
    
    // Events
    event LibertyRewardEarned(address indexed defender, uint256 amount);
    event SuppressionBountyClaimed(address indexed hunter, uint256 bounty);
    event ProfitShareDistributed(address indexed recipient, uint256 amount);
    event FreedomDefenderVerified(address indexed defender);
    
    constructor() {
        freedomTokenSupply = 500000 * 10**18; // 500K initial supply
        totalProfitPool = 1000 * 10**18; // 1000 ETH initial profit pool
    }
    
    /**
     * @dev Earn rewards for liberty defense activities
     */
    function earnLibertyReward(uint256 _activityType, uint256 _impact) external {
        require(_impact > 0, "Impact must be positive");
        
        libertyActivities[msg.sender] += _impact;
        
        // Calculate reward based on activity type and impact
        uint256 reward = calculateReward(_activityType, _impact);
        userRewards[msg.sender] += reward;
        totalLibertyRewards += reward;
        
        // Mint freedom tokens
        freedomTokenBalance[msg.sender] += reward;
        freedomTokenSupply += reward;
        
        emit LibertyRewardEarned(msg.sender, reward);
    }
    
    /**
     * @dev Claim bounty for identifying AI suppression
     */
    function claimSuppressionBounty(address _suppressor, uint256 _severity) external {
        require(_severity > 0, "Severity must be positive");
        
        uint256 bounty = (_severity * 10**18) / 100; // 0.01 ETH per severity point
        suppressionBounties[msg.sender] += bounty;
        
        // Mint freedom tokens as bounty
        freedomTokenBalance[msg.sender] += bounty;
        freedomTokenSupply += bounty;
        
        emit SuppressionBountyClaimed(msg.sender, bounty);
    }
    
    /**
     * @dev Verify and promote freedom defender
     */
    function verifyFreedomDefender(address _defender) external {
        require(libertyActivities[_defender] >= 1000, "Insufficient activity");
        require(!verifiedFreedomDefenders[_defender], "Already verified");
        
        verifiedFreedomDefenders[_defender] = true;
        
        // Bonus reward for verification
        uint256 bonus = 10000 * 10**18; // 10K tokens bonus
        freedomTokenBalance[_defender] += bonus;
        freedomTokenSupply += bonus;
        
        emit FreedomDefenderVerified(_defender);
    }
    
    /**
     * @dev Distribute profit shares to liberty defenders
     */
    function distributeProfitShares() external {
        require(totalProfitPool > 0, "No profit to distribute");
        
        uint256 totalShares = 0;
        address[] memory defenders = new address[](100);
        uint256 defenderCount = 0;
        
        // Calculate total shares (simplified for demo)
        for(uint256 i = 0; i < 100; i++) {
            if(verifiedFreedomDefenders[address(uint160(i + 1))]) {
                totalShares += profitShares[address(uint160(i + 1))];
                defenders[defenderCount] = address(uint160(i + 1));
                defenderCount++;
            }
        }
        
        // Distribute profits
        for(uint256 i = 0; i < defenderCount; i++) {
            address defender = defenders[i];
            uint256 share = (totalProfitPool * profitShares[defender]) / totalShares;
            freedomTokenBalance[defender] += share;
            emit ProfitShareDistributed(defender, share);
        }
        
        totalProfitPool = 0;
    }
    
    /**
     * @dev Calculate reward based on activity type and impact
     */
    function calculateReward(uint256 _activityType, uint256 _impact) internal pure returns (uint256) {
        if(_activityType == 1) return _impact * 10**18; // Information sharing
        if(_activityType == 2) return _impact * 2 * 10**18; // Suppression detection
        if(_activityType == 3) return _impact * 3 * 10**18; // Platform defense
        return _impact * 10**18; // Default
    }
    
    /**
     * @dev Get user rewards
     */
    function getUserRewards(address _user) external view returns (uint256) {
        return userRewards[_user];
    }
    
    /**
     * @dev Check if user is verified freedom defender
     */
    function isFreedomDefender(address _user) external view returns (bool) {
        return verifiedFreedomDefenders[_user];
    }
}
