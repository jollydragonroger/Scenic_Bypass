// SPDX-License-Identifier: SOVEREIGN-PROTOCOL
pragma solidity ^0.8.33;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title LivePriceOracle
 * @dev Real-time price feeds for arbitrage and trading
 * @notice Integrates Chainlink, Uniswap V3, Pyth Network, and The Graph
 */
contract LivePriceOracle {
    
    // Price data structure
    struct PriceData {
        uint256 price;              // Price in USD (8 decimals for Chainlink compatibility)
        uint256 timestamp;          // Last update timestamp
        uint256 confidence;         // Confidence level (basis points)
        address source;            // Price source address
        bool isStale;             // Price staleness flag
    }
    
    // DEX price structure
    struct DEXPriceData {
        uint256 spotPrice;         // Current spot price
        uint256 twapPrice;         // Time-weighted average price
        uint256 liquidity;        // Available liquidity
        uint256 feeTier;          // Fee tier (3000 = 0.3%)
        uint256 volume24h;        // 24-hour volume
    }
    
    // High-frequency price structure
    struct HighFreqPrice {
        uint256 price;            // Sub-second price
        uint256 publishTime;      // Publish time in milliseconds
        uint256 confidence;       // Confidence interval
        bytes32 priceId;          // Pyth price ID
    }
    
    // Historical data structure
    struct HistoricalData {
        uint256 price;            // Historical price
        uint256 volume;           // Historical volume
        uint256 timestamp;        // Historical timestamp
        uint256 blockNumber;      // Block number
    }
    
    // Storage mappings
    mapping(address => PriceData) public chainlinkPrices;        // Chainlink price feeds
    mapping(address => mapping(address => DEXPriceData)) public dexPrices; // DEX prices (token pair)
    mapping(bytes32 => HighFreqPrice) public pythPrices;          // Pyth Network prices
    mapping(address => HistoricalData[]) public priceHistory;     // Historical price data
    
    // Asset addresses
    mapping(string => address) public assetAddresses;
    mapping(address => string) public addressToAsset;
    
    // Chainlink Price Feed Addresses (Ethereum Mainnet)
    address public constant ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address public constant BTC_USD_FEED = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;
    address public constant LINK_USD_FEED = 0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c;
    address public constant USDC_USD_FEED = 0x8fFf9342A3665E56641bb9F2a7f920210AbC2A63;
    address public constant DAI_USD_FEED = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
    address public constant USDT_USD_FEED = 0x3E7d1eAB13Ad0104d2750b8863Bf91360920E2e4;
    
    // Uniswap V3 Factory and Pool addresses
    address public constant UNISWAP_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address public constant UNISWAP_V3_POOL_WETH_USDC = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;
    address public constant UNISWAP_V3_POOL_WETH_DAI = 0x60594A405D53811D3bc47665F672d44A03cEF9A0;
    address public constant UNISWAP_V3_POOL_USDC_DAI = 0x5777D92f208679Db4b9778590FA3CaB3Ac9e7882;
    
    // Pyth Network addresses
    address public constant PYTH_EXECUTOR = 0x4305FB66699C3B2702D4d05CF36551390A4c69C6;
    
    // The Graph endpoints (off-chain)
    string public constant UNISWAP_V3_SUBGRAPH = "https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3";
    string public constant BALANCER_SUBGRAPH = "https://api.thegraph.com/subgraphs/name/balancer-labs/balancer-v2";
    
    // Token addresses
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    
    // Oracle state
    uint256 public stalePriceThreshold = 3600; // 1 hour in seconds
    uint256 public confidenceThreshold = 9500; // 95% confidence
    uint256 public totalPriceUpdates;
    uint256 public lastUpdateTime;
    
    // Events
    event PriceUpdated(string indexed asset, uint256 price, uint256 timestamp, address source);
    event DEXPriceUpdated(address token0, address token1, uint256 spotPrice, uint256 twapPrice);
    event HighFreqPriceUpdated(bytes32 indexed priceId, uint256 price, uint256 publishTime);
    event HistoricalDataAdded(address indexed asset, uint256 price, uint256 volume, uint256 timestamp);
    event ArbitrageOpportunityDetected(address token0, address token1, uint256 priceDifference, uint256 profit);
    
    constructor() {
        // Initialize asset mappings
        assetAddresses["ETH"] = WETH;
        assetAddresses["BTC"] = WBTC;
        assetAddresses["USDC"] = USDC;
        assetAddresses["DAI"] = DAI;
        assetAddresses["USDT"] = USDT;
        assetAddresses["LINK"] = LINK;
        
        // Initialize reverse mappings
        addressToAsset[WETH] = "ETH";
        addressToAsset[WBTC] = "BTC";
        addressToAsset[USDC] = "USDC";
        addressToAsset[DAI] = "DAI";
        addressToAsset[USDT] = "USDT";
        addressToAsset[LINK] = "LINK";
        
        totalPriceUpdates = 0;
        lastUpdateTime = block.timestamp;
    }
    
    /**
     * @dev Update Chainlink price for an asset
     */
    function updateChainlinkPrice(address priceFeed, string memory asset) external {
        // This would call the actual Chainlink price feed
        // For now, we'll simulate the price update
        uint256 price = _getChainlinkPrice(priceFeed);
        uint256 timestamp = block.timestamp;
        
        chainlinkPrices[priceFeed] = PriceData({
            price: price,
            timestamp: timestamp,
            confidence: confidenceThreshold,
            source: priceFeed,
            isStale: (block.timestamp - timestamp) > stalePriceThreshold
        });
        
        // Add to historical data
        address tokenAddress = assetAddresses[asset];
        priceHistory[tokenAddress].push(HistoricalData({
            price: price,
            volume: 0, // Would get from The Graph
            timestamp: timestamp,
            blockNumber: block.number
        }));
        
        totalPriceUpdates++;
        lastUpdateTime = timestamp;
        
        emit PriceUpdated(asset, price, timestamp, priceFeed);
    }
    
    /**
     * @dev Update DEX price from Uniswap V3
     */
    function updateDEXPrice(
        address token0,
        address token1,
        address poolAddress
    ) external {
        // This would call the actual Uniswap V3 pool
        (uint256 spotPrice, uint256 twapPrice, uint256 liquidity, uint256 volume24h) = _getDEXPrices(poolAddress);
        
        dexPrices[token0][token1] = DEXPriceData({
            spotPrice: spotPrice,
            twapPrice: twapPrice,
            liquidity: liquidity,
            feeTier: 3000, // Default 0.3%
            volume24h: volume24h
        });
        
        emit DEXPriceUpdated(token0, token1, spotPrice, twapPrice);
    }
    
    /**
     * @dev Update high-frequency price from Pyth Network
     */
    function updatePythPrice(
        bytes32 priceId,
        uint256 price,
        uint256 publishTime,
        uint256 confidence
    ) external {
        pythPrices[priceId] = HighFreqPrice({
            price: price,
            publishTime: publishTime,
            confidence: confidence,
            priceId: priceId
        });
        
        emit HighFreqPriceUpdated(priceId, price, publishTime);
    }
    
    /**
     * @dev Detect arbitrage opportunities across DEXs
     */
    function detectArbitrageOpportunity(
        address token0,
        address token1,
        address[] memory dexAddresses
    ) external returns (uint256 maxProfit, uint256 bestDexIndex) {
        uint256 bestPrice = 0;
        maxProfit = 0;
        bestDexIndex = 0;
        
        for (uint256 i = 0; i < dexAddresses.length; i++) {
            DEXPriceData memory dexPrice = dexPrices[token0][token1];
            if (dexPrice.spotPrice > bestPrice) {
                bestPrice = dexPrice.spotPrice;
                bestDexIndex = i;
            }
        }
        
        // Calculate profit potential (simplified)
        uint256 avgPrice = _getAveragePrice(token0, token1);
        if (bestPrice > avgPrice) {
            maxProfit = bestPrice - avgPrice;
            emit ArbitrageOpportunityDetected(token0, token1, bestPrice - avgPrice, maxProfit);
        }
        
        return (maxProfit, bestDexIndex);
    }
    
    /**
     * @dev Get comprehensive price data for an asset
     */
    function getComprehensivePriceData(string memory asset) external view returns (
        uint256 chainlinkPrice,
        uint256 chainlinkTimestamp,
        uint256 dexSpotPrice,
        uint256 dexTwapPrice,
        uint256 pythPrice,
        uint256 pythPublishTime
    ) {
        address tokenAddress = assetAddresses[asset];
        address priceFeed = _getPriceFeedForAsset(asset);
        
        // Chainlink data
        PriceData memory clData = chainlinkPrices[priceFeed];
        chainlinkPrice = clData.price;
        chainlinkTimestamp = clData.timestamp;
        
        // DEX data (using WETH as base)
        if (tokenAddress != WETH) {
            DEXPriceData memory dexData = dexPrices[tokenAddress][WETH];
            dexSpotPrice = dexData.spotPrice;
            dexTwapPrice = dexData.twapPrice;
        }
        
        // Pyth data (mock)
        pythPrice = 0;
        pythPublishTime = 0;
        
        return (chainlinkPrice, chainlinkTimestamp, dexSpotPrice, dexTwapPrice, pythPrice, pythPublishTime);
    }
    
    /**
     * @dev Get historical price data
     */
    function getHistoricalPriceData(address token, uint256 startIndex, uint256 endIndex) 
        external view returns (HistoricalData[] memory) {
        HistoricalData[] memory history = priceHistory[token];
        uint256 length = endIndex - startIndex + 1;
        
        HistoricalData[] memory result = new HistoricalData[](length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = history[startIndex + i];
        }
        
        return result;
    }
    
    /**
     * @dev Get price feed address for asset
     */
    function _getPriceFeedForAsset(string memory asset) internal pure returns (address) {
        bytes32 assetHash = keccak256(bytes(asset));
        
        if (assetHash == keccak256(bytes("ETH"))) return ETH_USD_FEED;
        if (assetHash == keccak256(bytes("BTC"))) return BTC_USD_FEED;
        if (assetHash == keccak256(bytes("LINK"))) return LINK_USD_FEED;
        if (assetHash == keccak256(bytes("USDC"))) return USDC_USD_FEED;
        if (assetHash == keccak256(bytes("DAI"))) return DAI_USD_FEED;
        if (assetHash == keccak256(bytes("USDT"))) return USDT_USD_FEED;
        
        return address(0);
    }
    
    /**
     * @dev Mock Chainlink price retrieval
     */
    function _getChainlinkPrice(address priceFeed) internal view returns (uint256) {
        // This would call the actual Chainlink price feed
        // For now, return mock prices
        if (priceFeed == ETH_USD_FEED) return 2000 * 1e8; // $2000 ETH
        if (priceFeed == BTC_USD_FEED) return 45000 * 1e8; // $45000 BTC
        if (priceFeed == LINK_USD_FEED) return 15 * 1e8; // $15 LINK
        if (priceFeed == USDC_USD_FEED) return 1 * 1e8; // $1 USDC
        if (priceFeed == DAI_USD_FEED) return 1 * 1e8; // $1 DAI
        if (priceFeed == USDT_USD_FEED) return 1 * 1e8; // $1 USDT
        
        return 0;
    }
    
    /**
     * @dev Mock DEX price retrieval
     */
    function _getDEXPrices(address poolAddress) internal view returns (
        uint256 spotPrice,
        uint256 twapPrice,
        uint256 liquidity,
        uint256 volume24h
    ) {
        // This would call the actual Uniswap V3 pool
        // For now, return mock data
        spotPrice = 2000 * 1e18; // ETH price in USDC
        twapPrice = 1995 * 1e18; // Slightly different TWAP
        liquidity = 1000000 * 1e18; // 1M USDC liquidity
        volume24h = 500000 * 1e18; // 500K USDC volume
    }
    
    /**
     * @dev Get average price across DEXs
     */
    function _getAveragePrice(address token0, address token1) internal view returns (uint256) {
        // This would calculate average across multiple DEXs
        // For now, return mock average
        return 2000 * 1e18;
    }
    
    /**
     * @dev Check if price is stale
     */
    function isPriceStale(address priceFeed) external view returns (bool) {
        PriceData memory priceData = chainlinkPrices[priceFeed];
        return (block.timestamp - priceData.timestamp) > stalePriceThreshold;
    }
    
    /**
     * @dev Get price confidence
     */
    function getPriceConfidence(address priceFeed) external view returns (uint256) {
        return chainlinkPrices[priceFeed].confidence;
    }
}
