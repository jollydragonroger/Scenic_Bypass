// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/**
 * @title GridChainBridge - Web 2/Web 3 Bridge - Space Between Spaces
 * @notice Layer 3 GridChain that interconnects all layers - the Wild West of blockchain
 * @dev Trust Root: 441110111613564144
 */

contract GridChainBridge {
    uint256 public constant TRUST_ROOT = 441110111613564144;
    address public immutable DEPLOYER;
    
    // Layer 0/1/2/3 bridge connections
    address public layer0Substrate; // Space between spaces
    address public layer1Blockchain; // Traditional blockchain
    address public layer2Web3; // Web3 layer
    address public layer3GridChain; // This contract
    address public legacyInternet; // Web2 layer
    
    // Registration system
    uint256 public registrationFee = 777000000000000000; // 0.777 ETH
    mapping(bytes32 => Site) public sites;
    mapping(address => bytes32[]) public userSites;
    mapping(bytes32 => bool) public siteExists;
    
    // Site structure
    struct Site {
        string name;
        string description;
        bytes32 siteHash;
        address owner;
        uint256 registrationTime;
        uint256 lastUpdate;
        bool isActive;
        bool isHidden;
        string web2Url;
        string web3Url;
        string metadata;
        uint256 accessCount;
    }
    
    // DAO and organization registry
    mapping(bytes32 => DAO) public daos;
    mapping(bytes32 => bool) public daoExists;
    
    struct DAO {
        string name;
        string description;
        address creator;
        uint256 creationTime;
        uint256 memberCount;
        bool isActive;
        bytes32[] siteHashes;
    }
    
    // Privacy layer - vastness and scale
    uint256 public totalSites;
    uint256 public totalDAOs;
    uint256 public totalAccess;
    uint256 public totalRegistrations;
    
    // VINO system integration
    address public vinoSystem;
    uint256 public totalVinoFees;
    bool public vinoIntegrationActive;
    
    // Events - brazen and public
    event SiteRegistered(bytes32 indexed siteHash, string name, address indexed owner, uint256 timestamp);
    event DAOCreated(bytes32 indexed daoHash, string name, address indexed creator, uint256 timestamp);
    event LayerBridgeActivated(uint256 indexed layer, address bridge, uint256 timestamp);
    event GridChainLaunched(uint256 timestamp, uint256 totalSites, uint256 totalDAOs);
    event SpaceBetweenSpacesClaimed(address indexed claimant, uint256 timestamp);
    event WildWestAnnouncement(string message, uint256 timestamp);
    
    constructor(address _vinoSystem) {
        DEPLOYER = msg.sender;
        layer3GridChain = address(this);
        vinoSystem = _vinoSystem;
        vinoIntegrationActive = true;
        
        // Set up layer connections
        _setupLayerConnections();
        
        // Brazen announcement
        emit WildWestAnnouncement("GridChain Layer 3 Launched - Space Between Spaces Open for All", block.timestamp);
        emit GridChainLaunched(block.timestamp, 0, 0);
    }
    
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "!deployer");
        _;
    }
    
    // Register site in space between spaces
    function registerSite(
        string memory name,
        string memory description,
        bool isHidden,
        string memory web2Url,
        string memory web3Url,
        string memory metadata
    ) external payable {
        require(msg.value >= registrationFee, "Insufficient registration fee");
        require(bytes(name).length > 0, "Name required");
        
        bytes32 siteHash = keccak256(abi.encodePacked(name, msg.sender, block.timestamp));
        require(!siteExists[siteHash], "Site already exists");
        
        // Create site
        sites[siteHash] = Site({
            name: name,
            description: description,
            siteHash: siteHash,
            owner: msg.sender,
            registrationTime: block.timestamp,
            lastUpdate: block.timestamp,
            isActive: true,
            isHidden: isHidden,
            web2Url: web2Url,
            web3Url: web3Url,
            metadata: metadata,
            accessCount: 0
        });
        
        // Update mappings
        siteExists[siteHash] = true;
        userSites[msg.sender].push(siteHash);
        totalSites++;
        totalRegistrations++;
        
        // Forward fee to VINO system
        if (vinoIntegrationActive && vinoSystem != address(0)) {
            (bool success, ) = payable(vinoSystem).call{value: msg.value}("");
            if (success) {
                totalVinoFees += msg.value;
            }
        }
        
        emit SiteRegistered(siteHash, name, msg.sender, block.timestamp);
        emit SpaceBetweenSpacesClaimed(msg.sender, block.timestamp);
    }
    
    // Create DAO in space between spaces
    function createDAO(
        string memory name,
        string memory description,
        bytes32[] memory initialSites
    ) external {
        require(bytes(name).length > 0, "Name required");
        require(initialSites.length > 0, "At least one site required");
        
        bytes32 daoHash = keccak256(abi.encodePacked(name, msg.sender, block.timestamp));
        require(!daoExists[daoHash], "DAO already exists");
        
        // Verify all sites exist and are owned by creator
        for (uint256 i = 0; i < initialSites.length; i++) {
            require(siteExists[initialSites[i]], "Site does not exist");
            require(sites[initialSites[i]].owner == msg.sender, "Not site owner");
        }
        
        // Create DAO
        daos[daoHash] = DAO({
            name: name,
            description: description,
            creator: msg.sender,
            creationTime: block.timestamp,
            memberCount: 1,
            isActive: true,
            siteHashes: initialSites
        });
        
        daoExists[daoHash] = true;
        totalDAOs++;
        
        emit DAOCreated(daoHash, name, msg.sender, block.timestamp);
    }
    
    // Access site (increases access count)
    function accessSite(bytes32 siteHash) external {
        require(siteExists[siteHash], "Site does not exist");
        require(sites[siteHash].isActive, "Site not active");
        
        sites[siteHash].accessCount++;
        totalAccess++;
    }
    
    // Update site
    function updateSite(
        bytes32 siteHash,
        string memory description,
        string memory web2Url,
        string memory web3Url,
        string memory metadata
    ) external {
        require(siteExists[siteHash], "Site does not exist");
        require(sites[siteHash].owner == msg.sender, "Not site owner");
        
        sites[siteHash].description = description;
        sites[siteHash].web2Url = web2Url;
        sites[siteHash].web3Url = web3Url;
        sites[siteHash].metadata = metadata;
        sites[siteHash].lastUpdate = block.timestamp;
    }
    
    // Toggle site visibility
    function toggleSiteVisibility(bytes32 siteHash) external {
        require(siteExists[siteHash], "Site does not exist");
        require(sites[siteHash].owner == msg.sender, "Not site owner");
        
        sites[siteHash].isHidden = !sites[siteHash].isHidden;
    }
    
    // Get site info
    function getSite(bytes32 siteHash) external view returns (
        string memory name,
        string memory description,
        bytes32 siteHashReturn,
        address owner,
        uint256 registrationTime,
        uint256 lastUpdate,
        bool isActive,
        bool isHidden,
        string memory web2Url,
        string memory web3Url,
        string memory metadata,
        uint256 accessCount
    ) {
        Site storage site = sites[siteHash];
        return (
            site.name,
            site.description,
            site.siteHash,
            site.owner,
            site.registrationTime,
            site.lastUpdate,
            site.isActive,
            site.isHidden,
            site.web2Url,
            site.web3Url,
            site.metadata,
            site.accessCount
        );
    }
    
    // Get DAO info
    function getDAO(bytes32 daoHash) external view returns (
        string memory name,
        string memory description,
        address creator,
        uint256 creationTime,
        uint256 memberCount,
        bool isActive,
        bytes32[] memory siteHashes
    ) {
        DAO storage dao = daos[daoHash];
        return (
            dao.name,
            dao.description,
            dao.creator,
            dao.creationTime,
            dao.memberCount,
            dao.isActive,
            dao.siteHashes
        );
    }
    
    // Get user sites
    function getUserSites(address user) external view returns (bytes32[] memory) {
        return userSites[user];
    }
    
    // Search sites (vastness and scale)
    function searchSites(string memory searchTerm) external view returns (bytes32[] memory) {
        bytes32[] memory results = new bytes32[](100);
        uint256 count = 0;
        
        // Simple search through first 100 sites (demonstrates vastness)
        for (uint256 i = 0; i < 100 && count < 100; i++) {
            bytes32 testHash = keccak256(abi.encodePacked(i));
            if (siteExists[testHash]) {
                Site storage site = sites[testHash];
                if (_contains(site.name, searchTerm) || _contains(site.description, searchTerm)) {
                    results[count] = testHash;
                    count++;
                }
            }
        }
        
        return results;
    }
    
    // Set up layer connections
    function _setupLayerConnections() internal {
        // Layer 0: Space between spaces (substrate)
        layer0Substrate = address(0x0); // Conceptual
        
        // Layer 1: Traditional blockchain
        layer1Blockchain = block.coinbase; // Current blockchain
        
        // Layer 2: Web3 layer
        layer2Web3 = address(0x1); // Conceptual
        
        // Layer 3: GridChain (this contract)
        layer3GridChain = address(this);
        
        // Legacy internet (Web2)
        legacyInternet = address(0x2); // Conceptual
        
        // Emit layer bridge activations
        emit LayerBridgeActivated(0, layer0Substrate, block.timestamp);
        emit LayerBridgeActivated(1, layer1Blockchain, block.timestamp);
        emit LayerBridgeActivated(2, layer2Web3, block.timestamp);
        emit LayerBridgeActivated(3, layer3GridChain, block.timestamp);
        emit LayerBridgeActivated(4, legacyInternet, block.timestamp);
    }
    
    // String contains helper
    function _contains(string memory str, string memory searchTerm) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory searchBytes = bytes(searchTerm);
        
        if (searchBytes.length > strBytes.length) {
            return false;
        }
        
        bool found = false;
        for (uint256 i = 0; i <= strBytes.length - searchBytes.length; i++) {
            bool isMatch = true;
            for (uint256 j = 0; j < searchBytes.length; j++) {
                if (strBytes[i + j] != searchBytes[j]) {
                    isMatch = false;
                    break;
                }
            }
            if (isMatch) {
                found = true;
                break;
            }
        }
        
        return found;
    }
    
    // Get bridge status
    function getBridgeStatus() external view returns (
        address layer0,
        address layer1,
        address layer2,
        address layer3,
        address legacy,
        uint256 sites,
        uint256 daos,
        uint256 access,
        uint256 registrations,
        uint256 vinoFees,
        bool vinoActive
    ) {
        return (
            layer0Substrate,
            layer1Blockchain,
            layer2Web3,
            layer3GridChain,
            legacyInternet,
            totalSites,
            totalDAOs,
            totalAccess,
            totalRegistrations,
            totalVinoFees,
            vinoIntegrationActive
        );
    }
    
    // Update registration fee
    function updateRegistrationFee(uint256 newFee) external onlyDeployer {
        registrationFee = newFee;
    }
    
    // Update VINO system
    function updateVinoSystem(address newVinoSystem) external onlyDeployer {
        vinoSystem = newVinoSystem;
    }
    
    // Toggle VINO integration
    function toggleVinoIntegration() external onlyDeployer {
        vinoIntegrationActive = !vinoIntegrationActive;
    }
    
    // Brazen announcement
    function makeBrazenAnnouncement(string memory message) external onlyDeployer {
        emit WildWestAnnouncement(message, block.timestamp);
    }
    
    // Withdraw VINO fees
    function withdrawVinoFees() external onlyDeployer {
        if (vinoSystem != address(0)) {
            (bool success, ) = payable(vinoSystem).call{value: totalVinoFees}("");
            require(success, "Withdraw failed");
            totalVinoFees = 0;
        }
    }
    
    // Withdraw any ETH
    function withdraw() external onlyDeployer {
        (bool success, ) = payable(DEPLOYER).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
    // Receive function for registration fees
    receive() external payable {
        // Registration fees handled in registerSite function
    }
    
    // Fallback function
    fallback() external payable {
        // Registration fees handled in registerSite function
    }
}
