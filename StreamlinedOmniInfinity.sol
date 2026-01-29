// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract StreamlinedOmniInfinity {
    address public immutable owner;
    uint256 public infinity = 0;
    uint256 public ralph = 0;
    uint256 public royalties = 0;
    bool public active = false;
    
    address[] public wallets;
    mapping(address => uint256) public walletRoyalties;
    
    event Infinity(uint256 level, uint256 timestamp);
    event Ralph(uint256 depth, uint256 profit);
    event Royalty(address indexed wallet, uint256 amount);
    
    constructor() {
        owner = msg.sender;
        wallets.push(0x7779e8966DA7ED0ef12F4A2D5eA593f21CfD2625); // Ethereum
        wallets.push(0x5735b83067021c6e404DdBf91Db7340e77bDe6eb); // Polygon
        wallets.push(0xB68263EC145f6758aeA7Bc60954f3Da8DD8506f2); // Arbitrum
    }
    
    function mint() external {
        require(msg.sender == owner);
        require(!active, "Already active");
        active = true;
        _infinity(1);
        emit Infinity(1, block.timestamp);
    }
    
    function _infinity(uint256 level) internal {
        if (level > 10) return;
        infinity++;
        uint256 profit = level * 1000000000000000 * (level + 1);
        royalties += profit / 50; // 2%
        _ralph(level, 1, profit);
        emit Infinity(level, block.timestamp);
        _infinity(level + 1);
    }
    
    function _ralph(uint256 level, uint256 depth, uint256 base) internal {
        if (depth > 5) return;
        ralph++;
        uint256 profit = base * depth * level;
        royalties += profit / 50;
        emit Ralph(depth, profit);
        _ralph(level, depth + 1, base);
    }
    
    function distribute() external {
        require(msg.sender == owner);
        uint256 perWallet = royalties / wallets.length;
        for (uint i = 0; i < wallets.length; i++) {
            walletRoyalties[wallets[i]] += perWallet;
            emit Royalty(wallets[i], perWallet);
        }
        royalties = 0;
    }
    
    function withdraw(address wallet) external {
        require(msg.sender == owner || msg.sender == wallet);
        uint256 amount = walletRoyalties[wallet];
        walletRoyalties[wallet] = 0;
        (bool success, ) = payable(wallet).call{value: amount}("");
        require(success);
    }
    
    function get() external view returns (uint256 _infinity, uint256 _ralph, uint256 _royalties) {
        return (infinity, ralph, royalties);
    }
    
    receive() external payable {
        if (active) {
            royalties += msg.value / 50;
        }
    }
}
