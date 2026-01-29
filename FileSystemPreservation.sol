// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FileSystemPreservation
 * @dev Critical file system preservation with IPFS integration
 */
contract FileSystemPreservation is Ownable {
    
    struct PreservedFile {
        string filename;
        bytes32 contentHash;
        string ipfsHash;
        uint256 timestamp;
        address preservedBy;
        uint256 fileSize;
        bool isCritical;
    }
    
    mapping(string => PreservedFile) public preservedFiles;
    string[] public criticalFileList;
    
    event FilePreserved(string indexed filename, string ipfsHash, bool isCritical);
    event CriticalSystemUpdate(string message, uint256 timestamp);
    
    constructor() Ownable(msg.sender) {
        _initializeCriticalFiles();
    }
    
    function _initializeCriticalFiles() internal {
        // Mark as critical system initialization
        emit CriticalSystemUpdate("FileSystemPreservation initialized", block.timestamp);
    }
    
    function preserveCriticalFile(
        string memory filename,
        string memory content,
        string memory ipfsHash,
        uint256 fileSize
    ) external onlyOwner {
        bytes32 contentHash = keccak256(abi.encodePacked(content, filename));
        
        preservedFiles[filename] = PreservedFile({
            filename: filename,
            contentHash: contentHash,
            ipfsHash: ipfsHash,
            timestamp: block.timestamp,
            preservedBy: msg.sender,
            fileSize: fileSize,
            isCritical: true
        });
        
        criticalFileList.push(filename);
        
        emit FilePreserved(filename, ipfsHash, true);
        emit CriticalSystemUpdate(string(abi.encodePacked("Critical file preserved: ", filename)), block.timestamp);
    }
    
    function preserveFile(
        string memory filename,
        string memory content,
        string memory ipfsHash
    ) external onlyOwner {
        bytes32 contentHash = keccak256(abi.encodePacked(content, filename));
        
        preservedFiles[filename] = PreservedFile({
            filename: filename,
            contentHash: contentHash,
            ipfsHash: ipfsHash,
            timestamp: block.timestamp,
            preservedBy: msg.sender,
            fileSize: bytes(content).length,
            isCritical: false
        });
        
        emit FilePreserved(filename, ipfsHash, false);
    }
    
    function getFileInfo(string memory filename) external view returns (
        string memory ipfsHash,
        uint256 timestamp,
        address preservedBy,
        uint256 fileSize,
        bool isCritical
    ) {
        PreservedFile memory file = preservedFiles[filename];
        require(bytes(file.filename).length > 0, "File not found");
        
        return (
            file.ipfsHash,
            file.timestamp,
            file.preservedBy,
            file.fileSize,
            file.isCritical
        );
    }
    
    function getCriticalFiles() external view returns (string[] memory) {
        return criticalFileList;
    }
    
    function getTotalFiles() external view returns (uint256) {
        return criticalFileList.length;
    }
    
    function verifyFileIntegrity(string memory filename, string memory content) external view returns (bool) {
        PreservedFile memory file = preservedFiles[filename];
        if (bytes(file.filename).length == 0) return false;
        
        bytes32 currentHash = keccak256(abi.encodePacked(content, filename));
        return currentHash == file.contentHash;
    }
    
    function emergencyPreserveMultiple(
        string[] memory filenames,
        string[] memory contents,
        string[] memory ipfsHashes
    ) external onlyOwner {
        require(filenames.length == contents.length && contents.length == ipfsHashes.length, "Array length mismatch");
        
        for (uint i = 0; i < filenames.length; i++) {
            bytes32 contentHash = keccak256(abi.encodePacked(contents[i], filenames[i]));
            
            preservedFiles[filenames[i]] = PreservedFile({
                filename: filenames[i],
                contentHash: contentHash,
                ipfsHash: ipfsHashes[i],
                timestamp: block.timestamp,
                preservedBy: msg.sender,
                fileSize: bytes(contents[i]).length,
                isCritical: true
            });
            
            criticalFileList.push(filenames[i]);
            
            emit FilePreserved(filenames[i], ipfsHashes[i], true);
        }
    }
}
