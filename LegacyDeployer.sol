// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LegacyDeployer - Deploys LegacyBridge via SeedCapital
 * @notice Uses SeedCapital's ETH to deploy the large LegacyBridge
 * @dev Trust Root: 441110111613564144
 */

contract LegacyDeployer {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    address public legacyBridge;
    
    event LegacyBridgeDeployed(address indexed bridge);
    
    constructor() {
        DEPLOYER = msg.sender;
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    function deployLegacyBridge() external onlyDeployer {
        // Get LegacyBridge bytecode
        bytes memory bytecode = type(LegacyFinanceBridge).creationCode;
        
        // Deploy using contract's balance
        legacyBridge = new LegacyFinanceBridge{value: address(this).balance}();
        
        emit LegacyBridgeDeployed(legacyBridge);
    }
    
    receive() external payable {}
}
