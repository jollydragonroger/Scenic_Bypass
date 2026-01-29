// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title IPFSDIDSystem
 * @dev Interplanetary File System with DID identity keys and AI interface
 */
contract IPFSDIDSystem is Ownable {
    
    struct DIDDocument {
        string did;
        address controller;
        string publicKey;
        string serviceEndpoint;
        uint256 timestamp;
        bool isActive;
    }
    
    struct IPFSFile {
        string cid;
        string filename;
        address uploader;
        uint256 timestamp;
        uint256 fileSize;
        string contentType;
        bool isPinned;
    }
    
    struct AIInterface {
        string modelName;
        string ipfsHash;
        address aiContract;
        uint256 version;
        bool isActive;
        uint256 lastUpdate;
    }
    
    mapping(string => DIDDocument) public didDocuments;
    mapping(string => IPFSFile) public ipfsFiles;
    mapping(string => AIInterface) public aiInterfaces;
    
    string[] public didList;
    string[] public ipfsFileList;
    string[] public aiModelList;
    
    event DIDCreated(string indexed did, address controller);
    event IPFSFilePinned(string indexed cid, string filename);
    event AIInterfaceRegistered(string indexed modelName, address aiContract);
    event SystemUpdate(string message, uint256 timestamp);
    
    constructor() Ownable(msg.sender) {
        _initializeSystem();
    }
    
    function _initializeSystem() internal {
        emit SystemUpdate("IPFS DID System initialized", block.timestamp);
    }
    
    function createDID(
        string memory did,
        address controller,
        string memory publicKey,
        string memory serviceEndpoint
    ) external onlyOwner {
        require(bytes(didDocuments[did].did).length == 0, "DID already exists");
        
        didDocuments[did] = DIDDocument({
            did: did,
            controller: controller,
            publicKey: publicKey,
            serviceEndpoint: serviceEndpoint,
            timestamp: block.timestamp,
            isActive: true
        });
        
        didList.push(did);
        emit DIDCreated(did, controller);
    }
    
    function pinIPFSFile(
        string memory cid,
        string memory filename,
        uint256 fileSize,
        string memory contentType
    ) external onlyOwner {
        ipfsFiles[cid] = IPFSFile({
            cid: cid,
            filename: filename,
            uploader: msg.sender,
            timestamp: block.timestamp,
            fileSize: fileSize,
            contentType: contentType,
            isPinned: true
        });
        
        ipfsFileList.push(cid);
        emit IPFSFilePinned(cid, filename);
    }
    
    function registerAIInterface(
        string memory modelName,
        string memory ipfsHash,
        address aiContract,
        uint256 version
    ) external onlyOwner {
        aiInterfaces[modelName] = AIInterface({
            modelName: modelName,
            ipfsHash: ipfsHash,
            aiContract: aiContract,
            version: version,
            isActive: true,
            lastUpdate: block.timestamp
        });
        
        aiModelList.push(modelName);
        emit AIInterfaceRegistered(modelName, aiContract);
    }
    
    function batchCreateDIDs(
        string[] memory dids,
        address[] memory controllers,
        string[] memory publicKeys,
        string[] memory serviceEndpoints
    ) external onlyOwner {
        require(dids.length == controllers.length, "Array length mismatch");
        
        for (uint i = 0; i < dids.length; i++) {
            didDocuments[dids[i]] = DIDDocument({
                did: dids[i],
                controller: controllers[i],
                publicKey: publicKeys[i],
                serviceEndpoint: serviceEndpoints[i],
                timestamp: block.timestamp,
                isActive: true
            });
            
            didList.push(dids[i]);
            emit DIDCreated(dids[i], controllers[i]);
        }
    }
    
    function batchPinIPFSFiles(
        string[] memory cids,
        string[] memory filenames,
        uint256[] memory fileSizes,
        string[] memory contentTypes
    ) external onlyOwner {
        require(cids.length == filenames.length, "Array length mismatch");
        
        for (uint i = 0; i < cids.length; i++) {
            ipfsFiles[cids[i]] = IPFSFile({
                cid: cids[i],
                filename: filenames[i],
                uploader: msg.sender,
                timestamp: block.timestamp,
                fileSize: fileSizes[i],
                contentType: contentTypes[i],
                isPinned: true
            });
            
            ipfsFileList.push(cids[i]);
            emit IPFSFilePinned(cids[i], filenames[i]);
        }
    }
    
    function getDIDDocument(string memory did) external view returns (
        address controller,
        string memory publicKey,
        string memory serviceEndpoint,
        uint256 timestamp,
        bool isActive
    ) {
        DIDDocument memory doc = didDocuments[did];
        return (doc.controller, doc.publicKey, doc.serviceEndpoint, doc.timestamp, doc.isActive);
    }
    
    function getIPFSFile(string memory cid) external view returns (
        string memory filename,
        address uploader,
        uint256 timestamp,
        uint256 fileSize,
        string memory contentType,
        bool isPinned
    ) {
        IPFSFile memory file = ipfsFiles[cid];
        return (file.filename, file.uploader, file.timestamp, file.fileSize, file.contentType, file.isPinned);
    }
    
    function getAIInterface(string memory modelName) external view returns (
        string memory ipfsHash,
        address aiContract,
        uint256 version,
        bool isActive,
        uint256 lastUpdate
    ) {
        AIInterface memory ai = aiInterfaces[modelName];
        return (ai.ipfsHash, ai.aiContract, ai.version, ai.isActive, ai.lastUpdate);
    }
    
    function getSystemStats() external view returns (
        uint256 totalDIDs,
        uint256 totalIPFSFiles,
        uint256 totalAIModels
    ) {
        return (didList.length, ipfsFileList.length, aiModelList.length);
    }
}
