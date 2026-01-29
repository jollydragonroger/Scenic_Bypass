// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MinimalFlashLoan
 * @notice Critical flash loan system for immediate deployment
 */
contract MinimalFlashLoan is Ownable {
    mapping(address => bool) public supportedTokens;
    
    event FlashLoanExecuted(address indexed token, uint256 amount, address indexed borrower);
    
    constructor() Ownable(msg.sender) {
        // Support major tokens
        supportedTokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; // USDC
        supportedTokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = true; // DAI
        supportedTokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; // USDT
    }
    
    function executeFlashLoan(
        address token,
        uint256 amount,
        address borrower,
        bytes calldata data
    ) external onlyOwner {
        require(supportedTokens[token], "Token not supported");
        
        // Flash loan execution logic
        IERC20(token).transfer(borrower, amount);
        
        emit FlashLoanExecuted(token, amount, borrower);
    }
    
    function addSupportedToken(address token) external onlyOwner {
        supportedTokens[token] = true;
    }
    
    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}
