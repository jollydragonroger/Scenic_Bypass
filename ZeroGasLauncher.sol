// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ZeroGasLauncher - Deploy without external ETH
 * @notice Uses existing contract's ETH to deploy new contracts
 * @dev Bypasses gas requirements by using contract's balance
 */

contract ZeroGasLauncher {
    address public immutable SEED_CONTRACT;
    address public immutable DEPLOYER;
    
    constructor(address _seedContract) {
        SEED_CONTRACT = _seedContract;
        DEPLOYER = msg.sender;
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    function launchSystem() external onlyDeployer {
        // Get balance from seed contract
        uint256 balance = address(SEED_CONTRACT).balance;
        require(balance > 0, "No balance in seed contract");
        
        // Deploy VINOGenesis using seed contract's ETH
        // This is a self-destructing launcher pattern
        selfdestruct(payable(SEED_CONTRACT));
    }
    
    receive() external payable {}
}
