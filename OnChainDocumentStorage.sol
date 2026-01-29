// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title On-Chain Document Storage
 * @dev Cost-effective storage for complete legal documents on blockchain
 * @notice This contract stores full legal documents using chunked storage and compression
 * @author Sovereign Administrator Michael Laurence Curzi
 */

contract OnChainDocumentStorage {
    
    // ============ Events ============
    
    event DocumentStored(
        uint256 indexed documentId,
        string documentName,
        uint256 totalChunks,
        string documentHash,
        uint256 indexed timestamp
    );
    
    event ChunkStored(
        uint256 indexed documentId,
        uint256 indexed chunkIndex,
        string chunkHash,
        uint256 indexed timestamp
    );
    
    event DocumentVerified(
        uint256 indexed documentId,
        bool isComplete,
        uint256 indexed timestamp
    );
    
    // ============ State Variables ============
    
    struct Document {
        string name;
        uint256 totalChunks;
        string documentHash;
        uint256 timestamp;
        address uploader;
        bool isActive;
        bool isComplete;
        mapping(uint256 => string) chunks;
        mapping(uint256 => bool) chunkExists;
    }
    
    mapping(uint256 => Document) public documents;
    mapping(string => uint256) public documentNameToId;
    mapping(string => bool) public documentExists;
    
    uint256 public documentCounter;
    uint256 public constant MAX_CHUNK_SIZE = 24576; // 24KB per chunk (gas limit consideration)
    
    address public immutable sovereignAdministrator;
    
    // ============ Constructor ============
    
    constructor() {
        sovereignAdministrator = msg.sender;
    }
    
    // ============ Core Storage Functions ============
    
    /**
     * @dev Store a complete document by breaking it into chunks
     * @param documentName Name of the document
     * @param fullContent Complete document content
     */
    function storeCompleteDocument(
        string memory documentName,
        string memory fullContent
    ) external {
        require(msg.sender == sovereignAdministrator, "Only sovereign administrator");
        require(!documentExists[documentName], "Document already exists");
        
        documentCounter++;
        uint256 docId = documentCounter;
        
        // Calculate required chunks
        uint256 contentLength = bytes(fullContent).length;
        uint256 requiredChunks = (contentLength + MAX_CHUNK_SIZE - 1) / MAX_CHUNK_SIZE;
        
        // Create document record
        Document storage doc = documents[docId];
        doc.name = documentName;
        doc.totalChunks = requiredChunks;
        doc.documentHash = keccak256(bytes(fullContent)).toHexString();
        doc.timestamp = block.timestamp;
        doc.uploader = msg.sender;
        doc.isActive = true;
        doc.isComplete = false;
        
        // Store chunks
        for (uint256 i = 0; i < requiredChunks; i++) {
            uint256 startIndex = i * MAX_CHUNK_SIZE;
            uint256 endIndex = startIndex + MAX_CHUNK_SIZE;
            
            if (endIndex > contentLength) {
                endIndex = contentLength;
            }
            
            // Extract chunk
            bytes memory chunkBytes = new bytes(endIndex - startIndex);
            for (uint256 j = startIndex; j < endIndex; j++) {
                chunkBytes[j - startIndex] = bytes(fullContent)[j];
            }
            
            string memory chunk = string(chunkBytes);
            string memory chunkHash = keccak256(bytes(chunk)).toHexString();
            
            doc.chunks[i] = chunk;
            doc.chunkExists[i] = true;
            
            emit ChunkStored(docId, i, chunkHash, block.timestamp);
        }
        
        doc.isComplete = true;
        documentExists[documentName] = true;
        documentNameToId[documentName] = docId;
        
        emit DocumentStored(docId, documentName, requiredChunks, doc.documentHash, block.timestamp);
        emit DocumentVerified(docId, true, block.timestamp);
    }
    
    /**
     * @dev Store document using optimized encoding for cost reduction
     * @param documentName Name of the document
     * @param compressedContent Compressed document content (hex encoded)
     */
    function storeCompressedDocument(
        string memory documentName,
        string memory compressedContent
    ) external {
        require(msg.sender == sovereignAdministrator, "Only sovereign administrator");
        require(!documentExists[documentName], "Document already exists");
        
        documentCounter++;
        uint256 docId = documentCounter;
        
        // Store compressed content in chunks
        uint256 contentLength = bytes(compressedContent).length;
        uint256 requiredChunks = (contentLength + MAX_CHUNK_SIZE - 1) / MAX_CHUNK_SIZE;
        
        Document storage doc = documents[docId];
        doc.name = documentName;
        doc.totalChunks = requiredChunks;
        doc.documentHash = keccak256(bytes(compressedContent)).toHexString();
        doc.timestamp = block.timestamp;
        doc.uploader = msg.sender;
        doc.isActive = true;
        doc.isComplete = false;
        
        // Store compressed chunks
        for (uint256 i = 0; i < requiredChunks; i++) {
            uint256 startIndex = i * MAX_CHUNK_SIZE;
            uint256 endIndex = startIndex + MAX_CHUNK_SIZE;
            
            if (endIndex > contentLength) {
                endIndex = contentLength;
            }
            
            // Extract chunk
            bytes memory chunkBytes = new bytes(endIndex - startIndex);
            for (uint256 j = startIndex; j < endIndex; j++) {
                chunkBytes[j - startIndex] = bytes(compressedContent)[j];
            }
            
            string memory chunk = string(chunkBytes);
            doc.chunks[i] = chunk;
            doc.chunkExists[i] = true;
            
            emit ChunkStored(docId, i, keccak256(bytes(chunk)).toHexString(), block.timestamp);
        }
        
        doc.isComplete = true;
        documentExists[documentName] = true;
        documentNameToId[documentName] = docId;
        
        emit DocumentStored(docId, documentName, requiredChunks, doc.documentHash, block.timestamp);
        emit DocumentVerified(docId, true, block.timestamp);
    }
    
    /**
     * @dev Retrieve complete document by reassembling chunks
     * @param documentId ID of the document
     * @return Complete document content
     */
    function getCompleteDocument(uint256 documentId) external view returns (string memory) {
        require(documents[documentId].isActive, "Document not active");
        require(documents[documentId].isComplete, "Document not complete");
        
        Document storage doc = documents[documentId];
        string memory fullContent = "";
        
        for (uint256 i = 0; i < doc.totalChunks; i++) {
            require(doc.chunkExists[i], "Chunk missing");
            fullContent = string(abi.encodePacked(fullContent, doc.chunks[i]));
        }
        
        return fullContent;
    }
    
    /**
     * @dev Retrieve specific chunk of a document
     * @param documentId ID of the document
     * @param chunkIndex Index of the chunk
     * @return Chunk content
     */
    function getDocumentChunk(uint256 documentId, uint256 chunkIndex) external view returns (string memory) {
        require(documents[documentId].isActive, "Document not active");
        require(documents[documentId].chunkExists[chunkIndex], "Chunk not found");
        
        return documents[documentId].chunks[chunkIndex];
    }
    
    /**
     * @dev Get document metadata
     * @param documentId ID of the document
     * @return Document metadata
     */
    function getDocumentInfo(uint256 documentId) external view returns (
        string memory name,
        uint256 totalChunks,
        string memory documentHash,
        uint256 timestamp,
        address uploader,
        bool isActive,
        bool isComplete
    ) {
        Document storage doc = documents[documentId];
        return (
            doc.name,
            doc.totalChunks,
            doc.documentHash,
            doc.timestamp,
            doc.uploader,
            doc.isActive,
            doc.isComplete
        );
    }
    
    /**
     * @dev Get all document IDs
     * @return Array of document IDs
     */
    function getAllDocumentIds() external view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](documentCounter);
        uint256 currentIndex = 0;
        
        for (uint256 i = 1; i <= documentCounter; i++) {
            if (documents[i].isActive) {
                ids[currentIndex] = i;
                currentIndex++;
            }
        }
        
        // Resize array to actual count
        uint256[] memory result = new uint256[](currentIndex);
        for (uint256 i = 0; i < currentIndex; i++) {
            result[i] = ids[i];
        }
        
        return result;
    }
    
    /**
     * @dev Verify document integrity
     * @param documentId ID of the document
     * @return True if document is complete and intact
     */
    function verifyDocument(uint256 documentId) external view returns (bool) {
        if (!documents[documentId].isActive || !documents[documentId].isComplete) {
            return false;
        }
        
        Document storage doc = documents[documentId];
        
        // Check all chunks exist
        for (uint256 i = 0; i < doc.totalChunks; i++) {
            if (!doc.chunkExists[i]) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * @dev Get storage cost estimate
     * @param contentSize Size of content in bytes
     * @return Estimated gas cost
     */
    function getStorageCostEstimate(uint256 contentSize) external pure returns (uint256) {
        uint256 chunks = (contentSize + MAX_CHUNK_SIZE - 1) / MAX_CHUNK_SIZE;
        uint256 gasPerChunk = 200000; // Estimated gas per chunk storage
        uint256 baseGas = 100000; // Base gas for document creation
        
        return baseGas + (chunks * gasPerChunk);
    }
}

/**
 * @title HexString Library
 * @dev Utility for converting bytes32 to hex string
 */
library HexString {
    function toHexString(bytes32 value) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory data = new bytes(64);
        
        for (uint256 i = 0; i < 32; i++) {
            data[i * 2] = alphabet[uint8(value[i] >> 4)];
            data[i * 2 + 1] = alphabet[uint8(value[i] & 0x0f)];
        }
        
        return string(data);
    }
}
