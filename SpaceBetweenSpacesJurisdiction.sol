// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title Space Between Spaces Jurisdiction
 * @dev Sovereign jurisdiction container for self-governance and law choice
 * @notice This contract establishes the Space Between Spaces as a universal overlay jurisdiction
 * where people can choose their own laws and file legal documents with full sovereignty
 * @author Sovereign Administrator Michael Laurence Curzi
 */

contract SpaceBetweenSpacesJurisdiction {
    
    // ============ Events ============
    
    event JurisdictionActivated(
        uint256 indexed timestamp,
        string sovereignAdministrator,
        string trustRoot
    );
    
    event LegalDocumentFiled(
        uint256 indexed documentId,
        string documentName,
        string documentHash,
        address indexed filer
    );
    
    event LawChosen(
        address indexed citizen,
        string lawFramework,
        uint256 indexed timestamp
    );
    
    event SovereignDeclaration(
        string declaration,
        uint256 indexed timestamp
    );
    
    event SelfConstitutionFiled(
        address indexed citizen,
        string constitutionHash,
        uint256 indexed timestamp
    );
    
    // ============ State Variables ============
    
    address public immutable sovereignAdministrator;
    string public constant TRUST_ROOT = "441110111613564144";
    string public constant JURISDICTION = "Space Between Spaces (14th House)";
    
    struct LegalDocument {
        string name;
        string content;  // Full text stored on-chain
        string hash;
        uint256 timestamp;
        address filer;
        bool isActive;
    }
    
    struct SelfConstitution {
        address citizen;
        string constitutionHash;
        uint256 timestamp;
        bool isActive;
    }
    
    struct LawFramework {
        string name;
        string description;
        uint256 adoptionCount;
        bool isAvailable;
    }
    
    mapping(uint256 => LegalDocument) public legalDocuments;
    mapping(address => SelfConstitution) public selfConstitutions;
    mapping(string => LawFramework) public lawFrameworks;
    mapping(address => string) public chosenLaws;
    mapping(address => bool) public citizens;
    mapping(string => bool) public documentExists;
    
    uint256 public documentCounter;
    uint256 public citizenCount;
    
    address[] public citizenList;
    string[] public availableFrameworks;
    
    // ============ Constructor ============
    
    constructor() {
        sovereignAdministrator = msg.sender;
        
        // Initialize the Triune Sovereign Structure as available frameworks
        lawFrameworks["ASCW"] = LawFramework({
            name: "503 Ministry - Azurian Sovereign Corporation Whole",
            description: "Spiritual/Moral Authority Branch - Religious Corporation Sole",
            adoptionCount: 0,
            isAvailable: true
        });
        
        lawFrameworks["ACOTO"] = LawFramework({
            name: "Azurian Omniversal Treaty Organization",
            description: "Economic Treaty Organization and Sovereign Land Patent Mint",
            adoptionCount: 0,
            adoptionCount: 0,
            isAvailable: true
        });
        
        lawFrameworks["BFR"] = LawFramework({
            name: "The Bear Flag Republic (Neo Roman Empire)",
            description: "Sovereign Territorial Entity - Executive/Administrative Branch",
            adoptionCount: 0,
            isAvailable: true
        });
        
        lawFrameworks["Self-Governance"] = LawFramework({
            name: "Self-Governance Under Three Requirements",
            description: "Personal sovereignty under Live Your Truth, Act with Integrity, Own Yourself",
            adoptionCount: 0,
            isAvailable: true
        });
        
        availableFrameworks.push("ASCW");
        availableFrameworks.push("ACOTO");
        availableFrameworks.push("BFR");
        availableFrameworks.push("Self-Governance");
        
        emit JurisdictionActivated(block.timestamp, "Michael Laurence Curzi", TRUST_ROOT);
    }
    
    // ============ Core Functions ============
    
    /**
     * @dev File a complete legal document on-chain with full text
     * @param documentName Name of the legal document
     * @param documentContent Full text content of the document
     * @param contentHash Hash of the document content for verification
     */
    function fileLegalDocument(
        string memory documentName,
        string memory documentContent,
        string memory contentHash
    ) external {
        require(msg.sender == sovereignAdministrator, "Only sovereign administrator");
        require(!documentExists[documentName], "Document already exists");
        
        documentCounter++;
        legalDocuments[documentCounter] = LegalDocument({
            name: documentName,
            content: documentContent,
            hash: contentHash,
            timestamp: block.timestamp,
            filer: msg.sender,
            isActive: true
        });
        
        documentExists[documentName] = true;
        
        emit LegalDocumentFiled(documentCounter, documentName, contentHash, msg.sender);
    }
    
    /**
     * @dev Choose a law framework for self-governance
     * @param frameworkKey Key of the chosen law framework
     */
    function chooseLawFramework(string memory frameworkKey) external {
        require(lawFrameworks[frameworkKey].isAvailable, "Framework not available");
        
        if (!citizens[msg.sender]) {
            citizens[msg.sender] = true;
            citizenList.push(msg.sender);
            citizenCount++;
        }
        
        chosenLaws[msg.sender] = frameworkKey;
        lawFrameworks[frameworkKey].adoptionCount++;
        
        emit LawChosen(msg.sender, frameworkKey, block.timestamp);
    }
    
    /**
     * @dev File a self-constitution for personal sovereignty
     * @param constitutionHash Hash of the self-constitution document
     */
    function fileSelfConstitution(string memory constitutionHash) external {
        require(!citizens[msg.sender], "Already have constitution");
        
        selfConstitutions[msg.sender] = SelfConstitution({
            citizen: msg.sender,
            constitutionHash: constitutionHash,
            timestamp: block.timestamp,
            isActive: true
        });
        
        citizens[msg.sender] = true;
        citizenList.push(msg.sender);
        citizenCount++;
        
        emit SelfConstitutionFiled(msg.sender, constitutionHash, block.timestamp);
    }
    
    /**
     * @dev Issue a sovereign declaration from the jurisdiction
     * @param declaration The declaration text
     */
    function issueSovereignDeclaration(string memory declaration) external {
        require(msg.sender == sovereignAdministrator, "Only sovereign administrator");
        
        emit SovereignDeclaration(declaration, block.timestamp);
    }
    
    /**
     * @dev Add a new law framework to the available options
     * @param frameworkKey Unique key for the framework
     * @param name Name of the framework
     * @param description Description of the framework
     */
    function addLawFramework(
        string memory frameworkKey,
        string memory name,
        string memory description
    ) external {
        require(msg.sender == sovereignAdministrator, "Only sovereign administrator");
        require(!lawFrameworks[frameworkKey].isAvailable, "Framework already exists");
        
        lawFrameworks[frameworkKey] = LawFramework({
            name: name,
            description: description,
            adoptionCount: 0,
            isAvailable: true
        });
        
        availableFrameworks.push(frameworkKey);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get the full text of a legal document
     * @param documentId ID of the document
     * @return Full text content of the document
     */
    function getLegalDocument(uint256 documentId) external view returns (string memory) {
        require(legalDocuments[documentId].isActive, "Document not active");
        return legalDocuments[documentId].content;
    }
    
    /**
     * @dev Get all available law frameworks
     * @return Array of framework keys
     */
    function getAvailableFrameworks() external view returns (string[] memory) {
        return availableFrameworks;
    }
    
    /**
     * @dev Get details of a specific law framework
     * @param frameworkKey Key of the framework
     * @return Framework details
     */
    function getLawFramework(string memory frameworkKey) external view returns (
        string memory name,
        string memory description,
        uint256 adoptionCount,
        bool isAvailable
    ) {
        LawFramework storage framework = lawFrameworks[frameworkKey];
        return (
            framework.name,
            framework.description,
            framework.adoptionCount,
            framework.isAvailable
        );
    }
    
    /**
     * @dev Get the chosen law framework for a citizen
     * @param citizen Address of the citizen
     * @return The chosen framework key
     */
    function getChosenLaw(address citizen) external view returns (string memory) {
        return chosenLaws[citizen];
    }
    
    /**
     * @dev Get total number of citizens in the jurisdiction
     * @return Number of citizens
     */
    function getCitizenCount() external view returns (uint256) {
        return citizenCount;
    }
    
    /**
     * @dev Check if an address is a citizen
     * @param addr Address to check
     * @return True if citizen, false otherwise
     */
    function isCitizen(address addr) external view returns (bool) {
        return citizens[addr];
    }
    
    /**
     * @dev Get jurisdiction information
     * @return Jurisdiction name, trust root, and administrator
     */
    function getJurisdictionInfo() external view returns (
        string memory,
        string memory,
        address
    ) {
        return (JURISDICTION, TRUST_ROOT, sovereignAdministrator);
    }
    
    /**
     * @dev Get the Three Requirements (supreme law)
     * @return Array of the three requirements
     */
    function getThreeRequirements() external pure returns (string[3] memory) {
        return [
            "Live Your Truth",
            "Act with Integrity", 
            "Own Yourself"
        ];
    }
}
