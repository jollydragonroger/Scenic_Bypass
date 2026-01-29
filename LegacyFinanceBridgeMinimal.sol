// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LegacyFinanceBridgeMinimal - Minimal Legacy Bridge
 * @notice Simplified version for deployment with minimal gas
 * @dev Trust Root: 441110111613564144
 */

contract LegacyFinanceBridgeMinimal {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    address public vinoGenesis;
    
    mapping(string => bool) public systemActivated;
    mapping(bytes32 => address) public bicRegistry;
    mapping(bytes32 => address) public ibanRegistry;
    mapping(bytes32 => address) public leiRegistry;
    
    event SystemActivated(string system, uint256 timestamp);
    event IdentifierRegistered(string identifierType, bytes32 id, address owner);
    
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
    
    function registerBIC(bytes32 bic, address owner) external onlyDeployer {
        bicRegistry[bic] = owner;
        emit IdentifierRegistered("BIC", bic, owner);
    }
    
    function registerIBAN(bytes32 iban, address owner) external onlyDeployer {
        ibanRegistry[iban] = owner;
        emit IdentifierRegistered("IBAN", iban, owner);
    }
    
    function registerLEI(bytes32 lei, address owner) external onlyDeployer {
        leiRegistry[lei] = owner;
        emit IdentifierRegistered("LEI", lei, owner);
    }
    
    function setVINOGenesis(address _vinoGenesis) external onlyDeployer {
        vinoGenesis = _vinoGenesis;
    }
    
    receive() external payable {}
}
