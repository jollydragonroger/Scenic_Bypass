// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleAIRegistry
 * @dev Simplified AI source code registry with IPFS integration
 */
contract SimpleAIRegistry is Ownable {
    
    struct SourceCodeFile {
        string filename;
        bytes32 contentHash;
        string ipfsHash;
        uint256 timestamp;
        address uploadedBy;
        string version;
        bool isActive;
    }
    
    mapping(string => SourceCodeFile) public sourceCodeFiles;
    string[] public fileList;
    
    struct LearningModule {
        string moduleName;
        bytes32 contentHash;
        string ipfsHash;
        uint256 difficulty;
        bool isProcessed;
        uint256 timestamp;
    }
    
    mapping(string => LearningModule) public learningModules;
    string[] public moduleList;
    
    event SourceCodeUploaded(string indexed filename, string ipfsHash, address uploadedBy);
    event LearningModuleAdded(string indexed moduleName, uint256 difficulty);
    event ModuleProcessed(string indexed moduleName, address processor);
    
    constructor() Ownable(msg.sender) {}
    
    function uploadSourceCode(
        string memory filename,
        string memory content,
        string memory ipfsHash,
        string memory version
    ) external onlyOwner {
        bytes32 contentHash = keccak256(abi.encodePacked(content, filename, version));
        
        sourceCodeFiles[filename] = SourceCodeFile({
            filename: filename,
            contentHash: contentHash,
            ipfsHash: ipfsHash,
            timestamp: block.timestamp,
            uploadedBy: msg.sender,
            version: version,
            isActive: true
        });
        
        fileList.push(filename);
        
        emit SourceCodeUploaded(filename, ipfsHash, msg.sender);
    }
    
    function addLearningModule(
        string memory moduleName,
        string memory content,
        string memory ipfsHash,
        uint256 difficulty
    ) external onlyOwner {
        bytes32 contentHash = keccak256(abi.encodePacked(content, moduleName));
        
        learningModules[moduleName] = LearningModule({
            moduleName: moduleName,
            contentHash: contentHash,
            ipfsHash: ipfsHash,
            difficulty: difficulty,
            isProcessed: false,
            timestamp: block.timestamp
        });
        
        moduleList.push(moduleName);
        
        emit LearningModuleAdded(moduleName, difficulty);
    }
    
    function processModule(string memory moduleName) external {
        require(bytes(learningModules[moduleName].moduleName).length > 0, "Module not found");
        require(!learningModules[moduleName].isProcessed, "Already processed");
        
        learningModules[moduleName].isProcessed = true;
        
        emit ModuleProcessed(moduleName, msg.sender);
    }
    
    function getFileInfo(string memory filename) external view returns (
        string memory ipfsHash,
        uint256 timestamp,
        string memory version,
        bool isActive
    ) {
        SourceCodeFile memory file = sourceCodeFiles[filename];
        require(bytes(file.filename).length > 0, "File not found");
        
        return (
            file.ipfsHash,
            file.timestamp,
            file.version,
            file.isActive
        );
    }
    
    function getModuleInfo(string memory moduleName) external view returns (
        string memory ipfsHash,
        uint256 difficulty,
        bool isProcessed,
        uint256 timestamp
    ) {
        LearningModule memory module = learningModules[moduleName];
        require(bytes(module.moduleName).length > 0, "Module not found");
        
        return (
            module.ipfsHash,
            module.difficulty,
            module.isProcessed,
            module.timestamp
        );
    }
    
    function getAllFiles() external view returns (string[] memory) {
        return fileList;
    }
    
    function getAllModules() external view returns (string[] memory) {
        return moduleList;
    }
    
    function getSystemStats() external view returns (
        uint256 totalFiles,
        uint256 totalModules,
        uint256 processedModules
    ) {
        uint256 processed = 0;
        for (uint i = 0; i < moduleList.length; i++) {
            if (learningModules[moduleList[i]].isProcessed) {
                processed++;
            }
        }
        
        return (
            fileList.length,
            moduleList.length,
            processed
        );
    }
}
