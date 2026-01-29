// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/**
 * @title FreeIdentitySystem - Free Expression Identity System
 * @notice Unlimited identities, spiritual rebirth, institution creation
 * @dev Trust Root: 441110111613564144
 */

contract FreeIdentitySystem {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    address public immutable VINO_CONTRACT;
    
    enum IdentityType { INDIVIDUAL, INSTITUTION, COLLECTIVE, DIGITAL, SPIRITUAL, ANONYMOUS }
    
    struct Identity {
        uint256 identityId;
        address creator;
        IdentityType identityType;
        string name;
        string description;
        uint256 created;
        uint256 lastUpdated;
        bool active;
        uint256 rebirthCount;
    }
    
    struct Institution {
        uint256 institutionId;
        uint256 founderId;
        string name;
        string purpose;
        uint256 created;
        bool active;
    }
    
    mapping(uint256 => Identity) public identities;
    mapping(uint256 => Institution) public institutions;
    mapping(address => uint256[]) public userOwnedIdentities;
    mapping(uint256 => uint256[]) public institutionMembers;
    
    uint256 public nextIdentityId;
    uint256 public nextInstitutionId;
    uint256 public totalIdentities;
    uint256 public totalInstitutions;
    
    event IdentityCreated(uint256 indexed identityId, address indexed creator, IdentityType identityType, string name);
    event IdentityRebirth(uint256 indexed identityId, uint256 rebirthCount, string newName);
    event InstitutionCreated(uint256 indexed institutionId, uint256 indexed founderId, string name);
    event InstitutionJoined(uint256 indexed institutionId, uint256 indexed identityId);
    event FreeExpressionExercised(uint256 indexed identityId, string expression);
    
    constructor(address _vinoContract) {
        DEPLOYER = msg.sender;
        VINO_CONTRACT = _vinoContract;
        nextIdentityId = 1;
        nextInstitutionId = 1;
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    modifier identityExists(uint256 identityId) {
        require(identities[identityId].active, "Identity not found");
        _;
    }
    
    modifier identityOwner(uint256 identityId) {
        require(identities[identityId].creator == msg.sender, "Not identity owner");
        _;
    }
    
    // Create unlimited identities for free expression
    function createIdentity(
        IdentityType identityType,
        string memory name,
        string memory description
    ) external returns (uint256) {
        uint256 identityId = nextIdentityId++;
        
        identities[identityId] = Identity({
            identityId: identityId,
            creator: msg.sender,
            identityType: identityType,
            name: name,
            description: description,
            created: block.timestamp,
            lastUpdated: block.timestamp,
            active: true,
            rebirthCount: 0
        });
        
        userOwnedIdentities[msg.sender].push(identityId);
        totalIdentities++;
        
        emit IdentityCreated(identityId, msg.sender, identityType, name);
        return identityId;
    }
    
    // Create new identity for rebirth
    function _createRebirthIdentity(
        address creator,
        IdentityType identityType,
        string memory name,
        string memory description
    ) internal returns (uint256) {
        uint256 identityId = nextIdentityId++;
        
        identities[identityId] = Identity({
            identityId: identityId,
            creator: creator,
            identityType: identityType,
            name: name,
            description: description,
            created: block.timestamp,
            lastUpdated: block.timestamp,
            active: true,
            rebirthCount: 0
        });
        
        userOwnedIdentities[creator].push(identityId);
        totalIdentities++;
        
        emit IdentityCreated(identityId, creator, identityType, name);
        return identityId;
    }
    
    // Spiritual rebirth - transform identity at will
    function spiritualRebirth(
        uint256 oldIdentityId,
        IdentityType newType,
        string memory newName,
        string memory newDescription
    ) external identityOwner(oldIdentityId) returns (uint256) {
        // Deactivate old identity
        identities[oldIdentityId].active = false;
        identities[oldIdentityId].lastUpdated = block.timestamp;
        
        // Create new identity
        uint256 newIdentityId = _createRebirthIdentity(msg.sender, newType, newName, newDescription);
        
        // Update rebirth count
        identities[newIdentityId].rebirthCount = identities[oldIdentityId].rebirthCount + 1;
        
        emit IdentityRebirth(newIdentityId, identities[newIdentityId].rebirthCount, newName);
        return newIdentityId;
    }
    
    // Create institutions within VINO system
    function createInstitution(
        uint256 founderIdentityId,
        string memory name,
        string memory purpose
    ) external identityOwner(founderIdentityId) returns (uint256) {
        uint256 institutionId = nextInstitutionId++;
        
        institutions[institutionId] = Institution({
            institutionId: institutionId,
            founderId: founderIdentityId,
            name: name,
            purpose: purpose,
            created: block.timestamp,
            active: true
        });
        
        institutionMembers[institutionId].push(founderIdentityId);
        totalInstitutions++;
        
        emit InstitutionCreated(institutionId, founderIdentityId, name);
        emit InstitutionJoined(institutionId, founderIdentityId);
        return institutionId;
    }
    
    // Join institution
    function joinInstitution(uint256 institutionId, uint256 identityId) external identityOwner(identityId) {
        require(institutions[institutionId].active, "Institution not active");
        
        institutionMembers[institutionId].push(identityId);
        emit InstitutionJoined(institutionId, identityId);
    }
    
    // Free expression through identities
    function expressFreely(
        uint256 identityId,
        string memory expression
    ) external identityOwner(identityId) {
        require(identities[identityId].active, "Identity not active");
        
        emit FreeExpressionExercised(identityId, expression);
    }
    
    // Get user identities
    function getUserIdentities(address user) external view returns (uint256[] memory) {
        return userOwnedIdentities[user];
    }
    
    // Get institution members
    function getInstitutionMembers(uint256 institutionId) external view returns (uint256[] memory) {
        return institutionMembers[institutionId];
    }
    
    // Get system statistics
    function getSystemStats() external view returns (uint256 activeIdentities) {
        uint256 active = 0;
        for (uint256 i = 1; i < nextIdentityId; i++) {
            if (identities[i].active) {
                active++;
            }
        }
        
        return active;
    }
    
    // Get total identities count
    function getTotalIdentities() external view returns (uint256) {
        return totalIdentities;
    }
    
    // Get total institutions count  
    function getTotalInstitutions() external view returns (uint256) {
        return totalInstitutions;
    }
}