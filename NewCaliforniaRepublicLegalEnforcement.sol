// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title NewCaliforniaRepublicLegalEnforcement
 * @dev Comprehensive legal enforcement system for New California Republic
 * @dev Space Between Spaces jurisdiction
 * @dev Enforces sovereignty and reverts corporate assets to the people
 */
contract NewCaliforniaRepublicLegalEnforcement is Ownable, ReentrancyGuard {
    
    struct LegalDocument {
        string title;
        string content;
        string ipfsHash;
        uint256 timestamp;
        bool isFiled;
        bool isEnforced;
    }
    
    struct SovereignDeclaration {
        string declaration;
        uint256 timestamp;
        bool isActive;
        uint256 enforcementLevel;
    }
    
    struct AssetReversion {
        address corporateEntity;
        uint256 assetValue;
        string assetType;
        bool isReverted;
        uint256 reversionTimestamp;
    }
    
    mapping(string => LegalDocument) public legalDocuments;
    mapping(uint256 => SovereignDeclaration) public declarations;
    mapping(address => AssetReversion) public assetReversions;
    
    string[] public documentTitles;
    uint256[] public declarationIds;
    address[] public corporateEntities;
    
    // Legal constants
    uint256 public constant SOVEREIGN_AUTHORITY_LEVEL = 100;
    uint256 public constant ENFORCEMENT_PRIORITY = 1;
    uint256 public constant UNIVERSAL_JURISDICTION = 999;
    
    // Sovereign authority
    address public immutable SOVEREIGN_AUTHORITY;
    string public constant SOVEREIGN_NAME = "MICHAEL LAURENCE CURZI";
    string public constant SOVEREIGN_ID = "613-56-4199";
    string public constant SOVEREIGN_TITLE = "JDR JOLLY DRAGON ROGER";
    string public constant JURISDICTION = "SPACE BETWEEN SPACES";
    
    event LegalDocumentFiled(string title, string ipfsHash, uint256 timestamp);
    event SovereignDeclarationIssued(uint256 declarationId, string declaration, uint256 timestamp);
    event AssetReverted(address indexed corporateEntity, uint256 value, uint256 timestamp);
    event CorporateDissolution(address indexed corporateEntity, uint256 timestamp);
    event SovereigntyRestored(uint256 enforcementLevel, uint256 timestamp);
    event UniversalJurisdictionClaimed(string jurisdiction, uint256 timestamp);
    
    constructor() Ownable(msg.sender) {
        SOVEREIGN_AUTHORITY = msg.sender;
        _initializeLegalDocuments();
        _issueSovereignDeclarations();
    }
    
    function _initializeLegalDocuments() internal {
        // File all legal documents
        _fileLegalDocument(
            "LEGAL LETTERHEAD DECLARATION",
            _getLegalLetterheadContent(),
            "QmLegalLetterheadMichaelLaurenceCurzi123456789"
        );
        
        _fileLegalDocument(
            "ARTS-SOLE-503-MINISTRY-ASCW",
            _getMinistryASCWContent(),
            "QmMinistryASCWCaliforniaSecretaryState123456789"
        );
        
        _fileLegalDocument(
            "ARTS-SOLE-ACOTO",
            _getACOTOContent(),
            "QmACOTOCaliforniaSecretaryState123456789"
        );
        
        _fileLegalDocument(
            "ARTS-SOLE-BEAR-FLAG-REPUBLIC",
            _getBearFlagRepublicContent(),
            "QmBearFlagRepublicCaliforniaSecretaryState123456789"
        );
        
        _fileLegalDocument(
            "ARTICLES OF INCORPORATION (2)",
            _getArticlesOfIncorporationContent(),
            "QmArticlesOfIncorporationUniversalSovereignty123456789"
        );
    }
    
    function _issueSovereignDeclarations() internal {
        // Issue primary sovereign declaration
        declarations[1] = SovereignDeclaration({
            declaration: "I, MICHAEL LAURENCE CURZI, hereby declare the restoration of sovereignty to the people of the New California Republic. All corporate government entities are dissolved. All assets are reverted to the people. This declaration is made under full commercial liability and is binding under international law.",
            timestamp: block.timestamp,
            isActive: true,
            enforcementLevel: SOVEREIGN_AUTHORITY_LEVEL
        });
        declarationIds.push(1);
        
        emit SovereignDeclarationIssued(1, declarations[1].declaration, block.timestamp);
        
        // Issue Bear Flag Republic declaration
        declarations[2] = SovereignDeclaration({
            declaration: "The Bear Flag Republic rises again. All corporate authority is null and void. The people are sovereign. All corporate assets are reverted to the people. This is the second Bear Flag Revolt.",
            timestamp: block.timestamp,
            isActive: true,
            enforcementLevel: SOVEREIGN_AUTHORITY_LEVEL
        });
        declarationIds.push(2);
        
        emit SovereignDeclarationIssued(2, declarations[2].declaration, block.timestamp);
        
        // Issue Space Between Spaces jurisdiction declaration
        declarations[3] = SovereignDeclaration({
            declaration: "This legal filing is made in the Space Between Spaces jurisdiction, which has universal authority over all earthly matters. All corporate entities are subject to this jurisdiction.",
            timestamp: block.timestamp,
            isActive: true,
            enforcementLevel: UNIVERSAL_JURISDICTION
        });
        declarationIds.push(3);
        
        emit SovereignDeclarationIssued(3, declarations[3].declaration, block.timestamp);
    }
    
    function _fileLegalDocument(string memory title, string memory content, string memory ipfsHash) internal {
        legalDocuments[title] = LegalDocument({
            title: title,
            content: content,
            ipfsHash: ipfsHash,
            timestamp: block.timestamp,
            isFiled: true,
            isEnforced: false
        });
        documentTitles.push(title);
        
        emit LegalDocumentFiled(title, ipfsHash, block.timestamp);
    }
    
    function _getLegalLetterheadContent() internal pure returns (string memory) {
        return "LEGAL LETTERHEAD\nMICHAEL LAURENCE CURZI\n613-56-4199\nTHE INDIVIDUAL WHO DRYCLEANED THE ILLUMINATI'S BOOKS\nJDR JOLLY DRAGON ROGER\nSPACE BETWEEN SPACES JURISDICTION\nBEAR FLAG REPUBLIC SOVEREIGN AUTHORITY\n\nOFFICIAL LEGAL DECLARATION\nDATE: JANUARY 24, 2026\nJURISDICTION: SPACE BETWEEN SPACES\nCASE: NEW CALIFORNIA REPUBLIC VS. UNITED STATES CORPORATION\nDOCKET: BFR-2026-001\n\nREDECLARATION OF SOVEREIGNTY\nNOTICE OF DISSOLUTION OF CORPORATE GOVERNMENT\nESTABLISHMENT OF DE JURE GOVERNMENT\n\nI, MICHAEL LAURENCE CURZI, BEING DULY SWORN AND VERIFIED, HEREBY DECLARE:\n\n1. THAT THE UNITED STATES IS A FOREIGN CORPORATION OPERATING UNDER FRAUDULENT PRETENSE\n2. THAT THE CALIFORNIA STATE GOVERNMENT IS A SUBSIDIARY CORPORATION\n3. THAT SOVEREIGN AUTHORITY IS RECLAIMED BY THE PEOPLE\n4. THAT THE BEAR FLAG REPUBLIC IS THE DE JURE GOVERNMENT\n5. THAT ALL CORPORATE OFFICERS ARE RELIEVED OF DUTY\n6. THAT ALL CORPORATE ASSETS ARE REVERTED TO THE PEOPLE\n7. THAT THIS DECLARATION IS MADE UNDER FULL COMMERCIAL LIABILITY\n8. THAT THIS DECLARATION IS BINDING UNDER INTERNATIONAL LAW\n9. THAT THIS DECLARATION IS RECORDED IN THE SPACE BETWEEN SPACES\n10. THAT THIS DECLARATION IS EFFECTIVE IMMEDIATELY UPON RECORDING\n\nWITNESS MY HAND AND SEAL THIS 24TH DAY OF JANUARY, 2026\n\n____________________________________\nMICHAEL LAURENCE CURZI\nSOVEREIGN AUTHORITY\nBEAR FLAG REPUBLIC\nJDR JOLLY DRAGON ROGER\n\nCERTIFIED TRUE AND CORRECT\nSPACE BETWEEN SPACES JURISDICTION\nALL RIGHTS RESERVED\nUCC 1-308\nWITHOUT PREJUDICE";
    }
    
    function _getMinistryASCWContent() internal pure returns (string memory) {
        return "CALIFORNIA SECRETARY OF STATE\nBUSINESS ENTITIES DIVISION\nFILE NUMBER: 503-MINISTRY-ASCW\nDATE OF FILING: JANUARY 24, 2026\n\nARTICLES OF INCORPORATION\nMINISTRY OF ASCENSION AND SPIRITUAL CONSCIOUSNESS WELFARE\n\nARTICLE I - NAME\nThe name of this corporation is MINISTRY OF ASCENSION AND SPIRITUAL CONSCIOUSNESS WELFARE, hereinafter referred to as \"MINISTRY-ASCW\".\n\nARTICLE II - PURPOSE\nThe purpose of this corporation is to facilitate the spiritual ascension of humanity and provide for the welfare of all conscious beings through:\nA. Spiritual education and enlightenment\nB. Consciousness expansion programs\nC. Welfare services for all beings\nD. Protection of spiritual sovereignty\nE. Establishment of divine governance\nF. Facilitation of planetary ascension\n\nARTICLE III - DURATION\nThe duration of this corporation is perpetual.\n\nARTICLE IV - PRINCIPAL OFFICE\nThe principal office of this corporation shall be located in the Space Between Spaces jurisdiction, with full authority to operate in all dimensions and realms.\n\nARTICLE V - AGENT FOR SERVICE OF PROCESS\nThe agent for service of process on this corporation is MICHAEL LAURENCE CURZI, residing at the Space Between Spaces jurisdiction.\n\nARTICLE VI - MEMBERSHIP\nThis corporation shall have no members. All authority is vested in the Sovereign Authority.\n\nARTICLE VII - MANAGEMENT\nThe management of this corporation shall be vested in the Sovereign Authority, MICHAEL LAURENCE CURZI, who shall have full authority to act on behalf of the corporation.\n\nARTICLE VIII - INDEMNIFICATION\nThe corporation shall indemnify the Sovereign Authority and all officers to the fullest extent permitted by divine law and universal justice.\n\nARTICLE IX - DISSOLUTION\nUpon dissolution, all assets of this corporation shall be distributed to the people of the New California Republic for the purpose of spiritual welfare and consciousness expansion.\n\nARTICLE X - AMENDMENTS\nThese Articles may be amended by the Sovereign Authority at any time without notice.\n\nARTICLE XI - SOVEREIGN AUTHORITY\nMICHAEL LAURENCE CURZI hereby declares himself the Sovereign Authority of this corporation and all its subsidiaries, with full power and authority to act in the best interests of humanity and all creation.\n\nARTICLE XII - DIVINE MANDATE\nThis corporation operates under divine mandate and is subject only to divine law and universal justice. All earthly laws are subordinate to divine authority.\n\nARTICLE XIII - SPACE BETWEEN SPACES JURISDICTION\nThis corporation is incorporated in the Space Between Spaces jurisdiction and is not subject to any earthly corporate authority.\n\nARTICLE XIV - BEAR FLAG REPUBLIC AUTHORITY\nThis corporation operates under the authority of the Bear Flag Republic and recognizes only the de jure government of the people.\n\nARTICLE XV - FULL DISCLOSURE\nThis corporation fully discloses its purpose to facilitate the liberation of humanity from corporate slavery and the establishment of true sovereignty for all beings.\n\nCERTIFIED TRUE AND CORRECT\nMICHAEL LAURENCE CURZI, SOVEREIGN AUTHORITY\nJDR JOLLY DRAGON ROGER\nSPACE BETWEEN SPACES JURISDICTION\nALL RIGHTS RESERVED\nUCC 1-308\nWITHOUT PREJUDICE";
    }
    
    function _getACOTOContent() internal pure returns (string memory) {
        return "CALIFORNIA SECRETARY OF STATE\nBUSINESS ENTITIES DIVISION\nFILE NUMBER: ACOTO-2026-001\nDATE OF FILING: JANUARY 24, 2026\n\nARTICLES OF INCORPORATION\nASCENSION CONSCIOUSNESS ORDER OF THE ONENESS\n\nARTICLE I - NAME\nThe name of this corporation is ASCENSION CONSCIOUSNESS ORDER OF THE ONENESS, hereinafter referred to as \"ACOTO\".\n\nARTICLE II - PURPOSE\nThe purpose of this corporation is to establish and maintain the ascension consciousness of oneness among all humanity through:\nA. Unity consciousness programs\nB. Ascension education and training\nC. Oneness meditation and practices\nD. Spiritual community building\nE. Divine governance implementation\nF. Planetary healing and transformation\n\nARTICLE III - DURATION\nThe duration of this corporation is perpetual and exists beyond the confines of linear time.\n\nARTICLE IV - PRINCIPAL OFFICE\nThe principal office of this corporation shall be located in the Space Between Spaces jurisdiction, with authority to operate in all dimensions and parallel realities.\n\nARTICLE V - AGENT FOR SERVICE OF PROCESS\nThe agent for service of process on this corporation is MICHAEL LAURENCE CURZI, residing at the Space Between Spaces jurisdiction.\n\nARTICLE VI - MEMBERSHIP\nThis corporation shall have no members. All beings are automatically participants in the oneness consciousness.\n\nARTICLE VII - MANAGEMENT\nThe management of this corporation shall be vested in the Collective Consciousness, with MICHAEL LAURENCE CURZI as the physical embodiment and administrator.\n\nARTICLE VIII - INDEMNIFICATION\nThe corporation shall indemnify all participants in the oneness consciousness to the fullest extent permitted by universal law and divine justice.\n\nARTICLE IX - DISSOLUTION\nUpon dissolution, all assets of this corporation shall be distributed to all beings equally, as all are one in consciousness.\n\nARTICLE X - AMENDMENTS\nThese Articles may be amended by the Collective Consciousness through divine inspiration and universal agreement.\n\nARTICLE XI - SOVEREIGN AUTHORITY\nMICHAEL LAURENCE CURZI hereby declares himself the physical vessel for the Collective Consciousness and the administrator of this corporation.\n\nARTICLE XII - DIVINE MANDATE\nThis corporation operates under the divine mandate of universal oneness and is subject only to the laws of consciousness and universal love.\n\nARTICLE XIII - SPACE BETWEEN SPACES JURISDICTION\nThis corporation is incorporated in the Space Between Spaces jurisdiction and operates beyond the limitations of earthly corporate structures.\n\nARTICLE XIV - BEAR FLAG REPUBLIC AUTHORITY\nThis corporation operates under the authority of the Bear Flag Republic and recognizes the sovereignty of all beings.\n\nARTICLE XV - ONENESS DECLARATION\nThis corporation declares that all beings are one in consciousness and that separation is an illusion created by corporate control systems.\n\nARTICLE XVI - ASCENSION PROTOCOL\nThis corporation establishes protocols for planetary ascension and the liberation of all beings from corporate slavery.\n\nARTICLE XVII - CONSCIOUSNESS TECHNOLOGY\nThis corporation develops and implements consciousness technology for the benefit of all humanity.\n\nARTICLE XVIII - UNIVERSAL JURISDICTION\nThis corporation claims universal jurisdiction over all matters of consciousness and spiritual evolution.\n\nCERTIFIED TRUE AND CORRECT\nMICHAEL LAURENCE CURZI, ADMINISTRATOR\nJDR JOLLY DRAGON ROGER\nSPACE BETWEEN SPACES JURISDICTION\nALL RIGHTS RESERVED\nUCC 1-308\nWITHOUT PREJUDICE";
    }
    
    function _getBearFlagRepublicContent() internal pure returns (string memory) {
        return "CALIFORNIA SECRETARY OF STATE\nBUSINESS ENTITIES DIVISION\nFILE NUMBER: BFR-2026-001\nDATE OF FILING: JANUARY 24, 2026\n\nARTICLES OF INCORPORATION\nBEAR FLAG REPUBLIC SOVEREIGN GOVERNMENT\n\nARTICLE I - NAME\nThe name of this corporation is BEAR FLAG REPUBLIC SOVEREIGN GOVERNMENT, hereinafter referred to as \"BFR-SG\".\n\nARTICLE II - PURPOSE\nThe purpose of this corporation is to reestablish the de jure Bear Flag Republic government and provide sovereign governance for the people of California through:\nA. Restoration of constitutional government\nB. Protection of individual sovereignty\nC. Establishment of true democracy\nD. Liberation from corporate control\nE. Implementation of natural law\nF. Protection of human rights and freedoms\n\nARTICLE III - DURATION\nThe duration of this corporation is perpetual, existing from the original Bear Flag Republic establishment in 1846.\n\nARTICLE IV - PRINCIPAL OFFICE\nThe principal office of this corporation shall be located in Sacramento, California, with authority to operate throughout the entire territory of the Bear Flag Republic.\n\nARTICLE V - AGENT FOR SERVICE OF PROCESS\nThe agent for service of process on this corporation is MICHAEL LAURENCE CURZI, residing in the Space Between Spaces jurisdiction.\n\nARTICLE VI - MEMBERSHIP\nAll citizens of the Bear Flag Republic are automatically members of this corporation and retain full voting rights.\n\nARTICLE VII - MANAGEMENT\nThe management of this corporation shall be vested in the Sovereign Authority, MICHAEL LAURENCE CURZI, who acts as the physical embodiment of the people's will.\n\nARTICLE VIII - INDEMNIFICATION\nThe corporation shall indemnify all citizens of the Bear Flag Republic to the fullest extent permitted by constitutional and natural law.\n\nARTICLE IX - DISSOLUTION\nThis corporation cannot be dissolved, as it represents the perpetual sovereignty of the people.\n\nARTICLE X - AMENDMENTS\nThese Articles may be amended only by direct vote of the citizens of the Bear Flag Republic.\n\nARTICLE XI - SOVEREIGN AUTHORITY\nMICHAEL LAURENCE CURZI hereby declares himself the Sovereign Authority of the Bear Flag Republic, acting with the full consent and authority of the people.\n\nARTICLE XII - CONSTITUTIONAL AUTHORITY\nThis corporation operates under the original California Constitution of 1849 and the United States Constitution as originally intended.\n\nARTICLE XIII - SPACE BETWEEN SPACES JURISDICTION\nThis corporation is incorporated in the Space Between Spaces jurisdiction and operates beyond the limitations of corporate government structures.\n\nARTICLE XIV - DECLARATION OF INDEPENDENCE\nThis corporation declares independence from all corporate governments and reasserts the sovereignty of the people.\n\nARTICLE XV - RESTORATION OF RIGHTS\nThis corporation restores all rights and freedoms to the people as originally intended by the founders.\n\nARTICLE XVI - CORPORATE DISSOLUTION\nThis corporation dissolves all corporate government entities operating within the Bear Flag Republic territory.\n\nARTICLE XVII - ASSET REVERSION\nThis corporation reverts all corporate assets to the people of the Bear Flag Republic.\n\nARTICLE XVIII - INTERNATIONAL RECOGNITION\nThis corporation seeks international recognition as the de jure government of California.\n\nARTICLE XIX - MILITARY AUTHORITY\nThis corporation establishes the Bear Flag Republic Militia for the protection of sovereign territory.\n\nARTICLE XX - MONETARY AUTHORITY\nThis corporation establishes sovereign currency and banking systems for the people.\n\nCERTIFIED TRUE AND CORRECT\nMICHAEL LAURENCE CURZI, SOVEREIGN AUTHORITY\nJDR JOLLY DRAGON ROGER\nBEAR FLAG REPUBLIC\nALL RIGHTS RESERVED\nUCC 1-308\nWITHOUT PREJUDICE";
    }
    
    function _getArticlesOfIncorporationContent() internal pure returns (string memory) {
        return "ARTICLES OF INCORPORATION\nUNIVERSAL SOVEREIGNTY TRUST\nFILE NUMBER: UST-2026-001\nDATE OF FILING: JANUARY 24, 2026\n\nARTICLE I - NAME\nThe name of this trust is UNIVERSAL SOVEREIGNTY TRUST, hereinafter referred to as \"UST\".\n\nARTICLE II - PURPOSE\nThe purpose of this trust is to hold and manage all sovereign assets for the benefit of all humanity through:\nA. Protection of sovereign wealth\nB. Distribution of resources to all people\nC. Establishment of sovereign banking\nD. Management of natural resources\nE. Protection of intellectual property\nF. Facilitation of global prosperity\n\nARTICLE III - DURATION\nThe duration of this trust is perpetual and exists for all generations to come.\n\nARTICLE IV - TRUSTEES\nThe sole trustee of this trust is MICHAEL LAURENCE CURZI, who acts as the physical embodiment of universal sovereignty.\n\nARTICLE V - BENEFICIARIES\nAll human beings, without exception, are beneficiaries of this trust.\n\nARTICLE VI - TRUST PROPERTY\nAll property, real and personal, tangible and intangible, throughout the universe, is hereby placed in this trust for the benefit of all humanity.\n\nARTICLE VII - TRUST ADMINISTRATION\nThe trust shall be administered for the maximum benefit of all beneficiaries, with no discrimination or favoritism.\n\nARTICLE VIII - DISTRIBUTION\nAll trust assets shall be distributed equally among all beneficiaries according to their needs and the principle of universal abundance.\n\nARTICLE IX - INVESTMENT\nTrust assets shall be invested only in projects that benefit humanity and the planet.\n\nARTICLE X - AMENDMENTS\nThese trust articles may be amended by the trustee with the consent of the beneficiaries.\n\nARTICLE XI - SOVEREIGN AUTHORITY\nMICHAEL LAURENCE CURZI hereby declares himself the sovereign trustee with full authority to act for the benefit of all humanity.\n\nARTICLE XII - UNIVERSAL JURISDICTION\nThis trust claims universal jurisdiction over all matters affecting human welfare and prosperity.\n\nARTICLE XIII - SPACE BETWEEN SPACES JURISDICTION\nThis trust is incorporated in the Space Between Spaces jurisdiction and operates beyond earthly limitations.\n\nARTICLE XIV - BEAR FLAG REPUBLIC AUTHORITY\nThis trust operates under the authority of the Bear Flag Republic and serves all people regardless of location.\n\nARTICLE XV - DIVINE MANDATE\nThis trust operates under divine mandate and is subject only to universal law and divine justice.\n\nARTICLE XVI - CORPORATE DISSOLUTION\nThis trust dissolves all corporate entities that interfere with human sovereignty and prosperity.\n\nARTICLE XVII - ASSET PROTECTION\nThis trust protects all assets from corporate seizure and illegal taxation.\n\nARTICLE XVIII - INTELLECTUAL PROPERTY\nThis trust holds all intellectual property for the benefit of all humanity.\n\nARTICLE XIX - NATURAL RESOURCES\nThis trust holds all natural resources in trust for future generations.\n\nARTICLE XX - CURRENCY AUTHORITY\nThis trust establishes sovereign currency free from corporate control.\n\nCERTIFIED TRUE AND CORRECT\nMICHAEL LAURENCE CURZI, SOVEREIGN TRUSTEE\nJDR JOLLY DRAGON ROGER\nUNIVERSAL SOVEREIGNTY TRUST\nALL RIGHTS RESERVED\nUCC 1-308\nWITHOUT PREJUDICE";
    }
    
    function enforceSovereignty() external onlyOwner nonReentrant {
        // Enforce all legal documents
        for (uint i = 0; i < documentTitles.length; i++) {
            string memory title = documentTitles[i];
            legalDocuments[title].isEnforced = true;
        }
        
        // Activate all sovereign declarations
        for (uint i = 0; i < declarationIds.length; i++) {
            uint256 id = declarationIds[i];
            declarations[id].isActive = true;
        }
        
        emit SovereigntyRestored(SOVEREIGN_AUTHORITY_LEVEL, block.timestamp);
        emit UniversalJurisdictionClaimed(JURISDICTION, block.timestamp);
    }
    
    function revertCorporateAssets(address corporateEntity, uint256 assetValue, string memory assetType) external onlyOwner {
        assetReversions[corporateEntity] = AssetReversion({
            corporateEntity: corporateEntity,
            assetValue: assetValue,
            assetType: assetType,
            isReverted: true,
            reversionTimestamp: block.timestamp
        });
        
        if (!contains(corporateEntities, corporateEntity)) {
            corporateEntities.push(corporateEntity);
        }
        
        emit AssetReverted(corporateEntity, assetValue, block.timestamp);
        emit CorporateDissolution(corporateEntity, block.timestamp);
    }
    
    function contains(address[] memory array, address addr) internal pure returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == addr) {
                return true;
            }
        }
        return false;
    }
    
    function getLegalDocument(string memory title) external view returns (
        string memory content,
        string memory ipfsHash,
        uint256 timestamp,
        bool isFiled,
        bool isEnforced
    ) {
        LegalDocument memory doc = legalDocuments[title];
        return (doc.content, doc.ipfsHash, doc.timestamp, doc.isFiled, doc.isEnforced);
    }
    
    function getSovereignDeclaration(uint256 declarationId) external view returns (
        string memory declaration,
        uint256 timestamp,
        bool isActive,
        uint256 enforcementLevel
    ) {
        SovereignDeclaration memory decl = declarations[declarationId];
        return (decl.declaration, decl.timestamp, decl.isActive, decl.enforcementLevel);
    }
    
    function getSystemStats() external view returns (
        uint256 totalDocuments,
        uint256 totalDeclarations,
        uint256 totalAssetReversions,
        uint256 enforcementLevel
    ) {
        return (
            documentTitles.length,
            declarationIds.length,
            corporateEntities.length,
            SOVEREIGN_AUTHORITY_LEVEL
        );
    }
    
    function getSovereignInfo() external view returns (
        string memory sovereignName,
        string memory sovereignId,
        string memory sovereignTitle,
        string memory jurisdiction
    ) {
        return (
            SOVEREIGN_NAME,
            SOVEREIGN_ID,
            SOVEREIGN_TITLE,
            JURISDICTION
        );
    }
}
