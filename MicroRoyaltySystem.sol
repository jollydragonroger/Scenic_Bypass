// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title MicroRoyaltySystem - Smallest Possible Contract
 * @notice Ultra-minimal royalty collection system
 * @dev Trust Root: 441110111613564144
 */
contract MicroRoyaltySystem {
    address public immutable OWNER = 0xf37a2a2FE17Fa1ca8850516C7EbBAa56Cf001760;
    uint256 public constant ROYALTY_RATE = 777; // 7.77%
    uint256 public totalCollected;
    mapping(address => uint256) public balances;
    
    event RoyaltyCollected(address indexed from, uint256 amount);
    event RoyaltyWithdrawn(address indexed to, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == OWNER, "!owner");
        _;
    }
    
    function collectRoyalty(uint256 amount) external returns (uint256 royaltyAmount) {
        royaltyAmount = (amount * ROYALTY_RATE) / 10000;
        if (royaltyAmount > 0) {
            balances[OWNER] += royaltyAmount;
            totalCollected += royaltyAmount;
            emit RoyaltyCollected(msg.sender, royaltyAmount);
        }
        return royaltyAmount;
    }
    
    function withdraw() external onlyOwner {
        uint256 amount = balances[OWNER];
        if (amount > 0) {
            balances[OWNER] = 0;
            (bool success,) = payable(OWNER).call{value: amount}("");
            require(success, "Transfer failed");
            emit RoyaltyWithdrawn(OWNER, amount);
        }
    }
    
    function getRoyaltyAmount(uint256 amount) external pure returns (uint256) {
        return (amount * ROYALTY_RATE) / 10000;
    }
    
    receive() external payable {}
}
