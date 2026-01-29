// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./UniversalCurrencyReserve.sol";
import "./ShadowNetworkIntegration.sol";

/**
 * @title SimpleBroadcastSystem
 * @dev Efficient broadcast system for community engagement
 */
contract SimpleBroadcastSystem is Ownable {
    
    UniversalCurrencyReserve public universalReserve;
    ShadowNetworkIntegration public shadowNetwork;
    
    // Community targets
    address[] public communityTargets;
    mapping(address => bool) public hasBroadcasted;
    mapping(address => uint256) public broadcastTimestamp;
    
    uint256 public totalBroadcasts;
    uint256 public constant BROADCAST_GAS_LIMIT = 100000;
    
    event BroadcastSent(
        address indexed target,
        string message,
        uint256 timestamp,
        uint256 gasUsed
    );
    
    event GlobalBroadcastComplete(
        uint256 totalTargets,
        uint256 successfulBroadcasts,
        uint256 timestamp
    );
    
    constructor(address _universalReserve, address _shadowNetwork) Ownable(msg.sender) {
        universalReserve = UniversalCurrencyReserve(_universalReserve);
        shadowNetwork = ShadowNetworkIntegration(_shadowNetwork);
        
        _initializeCommunityTargets();
        _executeGlobalBroadcast();
    }
    
    function _initializeCommunityTargets() internal {
        // Add major community addresses
        communityTargets.push(address(0xBd3531dA5CF5857e7CfAA92426877b022e612cf8)); // Pudgy Penguins
        communityTargets.push(address(0x364C828eE171616a39897688A831c2499aD972ec)); // Sappy Seals
        communityTargets.push(address(0x81aae81b7b914b76F4F49AF2B1dc10295Cb020fa)); // Laughing Sigh Fox
        communityTargets.push(address(0x11aC6aF070Fe1991a457c56FB85c577EFE57F0e4)); // Dragon King
        communityTargets.push(address(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7)); // Loot
        communityTargets.push(address(0xcafE1A77e84698c83CA8931F54A755176eF75f2C)); // Aragon Network
        communityTargets.push(address(0xdE30da39c46104798BB5aa3fe8b9E0e7F3Ec3F66)); // Gitcoin
        communityTargets.push(address(0xB261cC35D4540d58820bD7080E72c842B10a2665)); // Minds
        communityTargets.push(address(0x00000000FcAFAD24239B090C4d9691712d02613b)); // Farcaster
        communityTargets.push(address(0xd1ad5694d87Dac749193C297926396F600d3c3C2)); // Zora
        communityTargets.push(address(0x220866B1a2219f40e72f5c628cA3A9D)); // Vitalik
        communityTargets.push(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)); // WETH
        
        // Add our existing contracts
        communityTargets.push(address(universalReserve));
        communityTargets.push(address(shadowNetwork));
    }
    
    function _executeGlobalBroadcast() internal {
        uint256 successfulBroadcasts = 0;
        
        for (uint i = 0; i < communityTargets.length; i++) {
            (bool success, uint256 gasUsed) = _broadcastToTarget(communityTargets[i]);
            if (success) {
                successfulBroadcasts++;
            }
        }
        
        emit GlobalBroadcastComplete(
            communityTargets.length,
            successfulBroadcasts,
            block.timestamp
        );
    }
    
    function _broadcastToTarget(address target) internal returns (bool success, uint256 gasUsed) {
        if (hasBroadcasted[target]) {
            return (false, 0);
        }
        
        string memory message = _generateBroadcastMessage(target);
        
        uint256 gasStart = gasleft();
        
        // Attempt to call the target
        (success, ) = target.call{gas: BROADCAST_GAS_LIMIT}(
            abi.encodeWithSignature("broadcastMessage(string)", message)
        );
        
        gasUsed = gasStart - gasleft();
        
        // Record the broadcast attempt
        hasBroadcasted[target] = true;
        broadcastTimestamp[target] = block.timestamp;
        totalBroadcasts++;
        
        emit BroadcastSent(target, message, block.timestamp, gasUsed);
        
        return (success, gasUsed);
    }
    
    function _generateBroadcastMessage(address target) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "GLOBAL ECONOMIC RESET BROADCAST - One Piece Found! ",
            "The treasure covers the whole planet! All 8+ billion family members welcome! ",
            "Arbitrage profits shared with community! ",
            "Target: ", _addressToString(target),
            " - Join the One Piece era!"
        ));
    }
    
    function _addressToString(address addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(addr)));
        bytes memory alphabet = "0123456789abcdef";
        
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        
        for (uint i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        
        return string(str);
    }
    
    function manualBroadcast(address target) external onlyOwner {
        (bool success, uint256 gasUsed) = _broadcastToTarget(target);
        require(success, "Broadcast failed");
    }
    
    function getBroadcastStats() external view returns (
        uint256 total,
        uint256 targets,
        uint256 timestamp
    ) {
        return (
            totalBroadcasts,
            communityTargets.length,
            block.timestamp
        );
    }
    
    function wasBroadcasted(address target) external view returns (bool, uint256) {
        return (hasBroadcasted[target], broadcastTimestamp[target]);
    }
}
