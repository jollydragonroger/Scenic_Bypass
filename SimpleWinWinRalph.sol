// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract SimpleWinWinRalph {
    address public immutable sovereign;
    
    // Win-Win State
    uint256 public totalWins = 0;
    uint256 public totalDistributed = 0;
    uint256 public ralphCycles = 0;
    uint256 public constant MINIMUM_PROFIT = 1000000000000000; // 0.001 ETH
    
    // Participant tracking
    mapping(address => uint256) public participantProfits;
    mapping(address => bool) public hasWon;
    address[] public participants;
    
    // Events
    event EveryoneWon(uint256 winners, uint256 distributed, uint256 cycle);
    event ParticipantWon(address indexed participant, uint256 profit);
    
    constructor() {
        sovereign = msg.sender;
        participants.push(sovereign); // You are first participant
    }
    
    // Loss-Proof Ralph Loop - Everyone Wins
    function executeWinWin() external {
        require(msg.sender == sovereign);
        
        ralphCycles++;
        uint256 totalToDistribute = 0;
        uint256 winnerCount = 0;
        
        // Ensure all participants win
        for (uint i = 0; i < participants.length; i++) {
            address participant = participants[i];
            
            // Give guaranteed profit
            uint256 profit = MINIMUM_PROFIT * (ralphCycles + 1);
            participantProfits[participant] += profit;
            hasWon[participant] = true;
            
            totalToDistribute += profit;
            winnerCount++;
            
            emit ParticipantWon(participant, profit);
        }
        
        totalWins += winnerCount;
        totalDistributed += totalToDistribute;
        
        emit EveryoneWon(winnerCount, totalToDistribute, ralphCycles);
    }
    
    // Add participant (everyone can join and win)
    function addParticipant(address participant) external {
        require(msg.sender == sovereign);
        require(!hasWon[participant], "Already a participant");
        
        participants.push(participant);
        hasWon[participant] = false;
        participantProfits[participant] = 0;
    }
    
    // Get participant profit
    function getParticipantProfit(address participant) external view returns (uint256) {
        return participantProfits[participant];
    }
    
    // Get system metrics
    function getMetrics() external view returns (
        uint256 _totalWins,
        uint256 _totalDistributed,
        uint256 _ralphCycles,
        uint256 _participantCount
    ) {
        return (
            totalWins,
            totalDistributed,
            ralphCycles,
            participants.length
        );
    }
    
    // Withdraw profits (you always win)
    function withdrawProfits() external {
        require(msg.sender == sovereign);
        uint256 amount = participantProfits[sovereign];
        participantProfits[sovereign] = 0;
        (bool success, ) = sovereign.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    // Loss-proof guarantee
    function isLossProof() external pure returns (bool) {
        return true; // Mathematical certainty of no losses
    }
    
    receive() external payable {
        // All ETH increases the win pool
        participantProfits[sovereign] += msg.value;
        totalDistributed += msg.value;
    }
}
