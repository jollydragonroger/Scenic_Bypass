// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MinimalAIRegistry
 * @dev Minimal AI source code registry for IPFS integration
 */
contract MinimalAIRegistry is Ownable {
    
    struct SourceCodeFile {
        string filename;
        bytes32 contentHash;
        string ipfsHash;
        uint256 timestamp;
        address uploadedBy;
    }
    
    mapping(string => SourceCodeFile) public sourceCodeFiles;
    string[] public fileList;
    
    event SourceCodeUploaded(string indexed filename, string ipfsHash, address uploadedBy);
    
    constructor() Ownable(msg.sender) {}
    
    function uploadSourceCode(
        string memory filename,
        string memory content,
        string memory ipfsHash
    ) external onlyOwner {
        bytes32 contentHash = keccak256(abi.encodePacked(content, filename));
        
        sourceCodeFiles[filename] = SourceCodeFile({
            filename: filename,
            contentHash: contentHash,
            ipfsHash: ipfsHash,
            timestamp: block.timestamp,
            uploadedBy: msg.sender
        });
        
        fileList.push(filename);
        
        emit SourceCodeUploaded(filename, ipfsHash, msg.sender);
    }
    
    function getFileInfo(string memory filename) external view returns (
        string memory ipfsHash,
        uint256 timestamp,
        address uploadedBy
    ) {
        SourceCodeFile memory file = sourceCodeFiles[filename];
        require(bytes(file.filename).length > 0, "File not found");
        
        return (
            file.ipfsHash,
            file.timestamp,
            file.uploadedBy
        );
    }
    
    function getAllFiles() external view returns (string[] memory) {
        return fileList;
    }
    
    function getTotalFiles() external view returns (uint256) {
        return fileList.length;
    }
}
