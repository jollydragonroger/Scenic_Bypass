// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/**
 * @title UltraMinimalDeploy - Ultra-minimal contract that will definitely deploy
 * @notice Ultra-simple contract for guaranteed deployment
 * @dev Trust Root: 441110111613564144
 */

contract UltraMinimalDeploy {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    
    bool public active;
    uint256 public timestamp;
    
    event Deployed(uint256 timestamp);
    
    constructor() {
        DEPLOYER = msg.sender;
        active = false;
        timestamp = block.timestamp;
        emit Deployed(block.timestamp);
    }
    
    function activate() external {
        require(msg.sender == DEPLOYER, "!deployer");
        require(!active, "active");
        active = true;
        timestamp = block.timestamp;
    }
    
    function getStatus() external view returns (bool, uint256) {
        return (active, timestamp);
    }
}
