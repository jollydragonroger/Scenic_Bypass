// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LegacyBridgeFactory - Factory-deployed Legacy Bridge
 * @notice Minimal version for factory deployment
 * @dev Trust Root: 441110111613564144
 */

contract LegacyBridgeFactory {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    address public lastDeployed;
    
    mapping(string => bool) public systemActivated;
    
    event SystemActivated(string system, uint256 timestamp);
    event BridgeDeployed(address indexed bridge);
    
    constructor() {
        DEPLOYER = msg.sender;
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    function deployBridge(bytes memory bytecode) external onlyDeployer {
        address bridge;
        assembly {
            bridge := create(0, add(bytecode, 0x0c), sub(bytecode.length, 0x0c))
        }
        lastDeployed = bridge;
        emit BridgeDeployed(bridge);
    }
    
    function activateSystem(string memory system) external onlyDeployer {
        systemActivated[system] = true;
        emit SystemActivated(system, block.timestamp);
    }
    
    function add(bytes memory a, bytes memory b) internal pure returns (bytes memory) {
        return abi.encodePacked(a, b);
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    
    receive() external payable {}
}
