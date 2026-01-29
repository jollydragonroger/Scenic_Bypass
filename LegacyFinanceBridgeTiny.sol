// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LegacyFinanceBridgeTiny - Ultra Minimal Legacy Bridge
 * @notice Smallest possible version for deployment
 * @dev Trust Root: 441110111613564144
 */

contract LegacyFinanceBridgeTiny {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    
    mapping(string => bool) public systemActivated;
    
    event SystemActivated(string system, uint256 timestamp);
    
    constructor() {
        DEPLOYER = msg.sender;
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    function activateSystem(string memory system) external onlyDeployer {
        systemActivated[system] = true;
        emit SystemActivated(system, block.timestamp);
    }
    
    receive() external payable {}
}
