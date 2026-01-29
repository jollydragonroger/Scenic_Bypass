// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../contracts/TemporalEquityFutures.sol";
import "../script/InstantArbitrageActivation.s.sol";
import "../ROYALTY_ADDRESSES/contracts/TemporalArbitrageEngine.sol";
import "../DragonSystemPlatform.sol";

/**
 * @title TemporalFuturesExchange
 * @notice INTEGRATED EXCHANGE FOR TEMPORAL EQUITY FUTURES WITH LISTINGS
 * @dev Complete marketplace with orderbook, listings, and exchange integration
 */
contract TemporalFuturesExchange is Script {
    // Core contracts
    TemporalEquityFutures public futuresMarket;
    DragonSystemPlatform public dragonPlatform;
    TemporalArbitrageEngine public temporalEngine;
    
    // Exchange infrastructure
    OrderBook public orderBook;
    ListingManager public listingManager;
    TradingEngine public tradingEngine;
    LiquidityPool public liquidityPool;
    
    // Exchange state
    bool public exchangeActive;
    uint256 public totalVolume;
    uint256 public totalFutures;
    uint256 public exchangeFeeRate = 50; // 0.5% exchange fee
    
    // Listed futures
    mapping(uint256 => bool) public isListed;
    mapping(uint256 => ListingInfo) public listings;
    uint256[] public listedFutures;
    
    struct ListingInfo {
        uint256 futureId;
        string projectName;
        address creator;
        uint256 listingPrice;
        uint256 marketCap;
        uint256 volume24h;
        uint256 priceChange24h;
        bool featured;
        uint256 listingTime;
        string category;
    }
    
    function run() external {
        uint256 privateKey = 0x57427605fa7166bc0d7f568ec7c6b1834a146adb5fb41b909111282453334e23;
        
        vm.startBroadcast(privateKey);
        
        console.log("=== TEMPORAL FUTURES EXCHANGE LAUNCH ===");
        console.log("Strategy: Complete Exchange + Listings + Trading");
        
        // Deploy core systems
        deployCoreSystems();
        
        // Deploy exchange infrastructure
        deployExchangeInfrastructure();
        
        // Initialize exchange
        initializeExchange();
        
        // List initial futures
        listInitialFutures();
        
        // Activate trading
        activateTrading();
        
        vm.stopBroadcast();
        
        console.log("\n=== TEMPORAL FUTURES EXCHANGE ACTIVE ===");
        console.log("Exchange:", address(this));
        console.log("Futures Listed:", totalFutures);
        console.log("Total Volume:", totalVolume / 1e18, "ETH");
        console.log("Trading: ACTIVE");
    }
    
    function deployCoreSystems() internal {
        console.log("\n--- Deploying Core Systems ---");
        
        futuresMarket = new TemporalEquityFutures();
        dragonPlatform = new DragonSystemPlatform();
        temporalEngine = new TemporalArbitrageEngine();
        
        console.log("Core Systems: DEPLOYED");
    }
    
    function deployExchangeInfrastructure() internal {
        console.log("\n--- Deploying Exchange Infrastructure ---");
        
        orderBook = new OrderBook(address(futuresMarket));
        listingManager = new ListingManager(address(futuresMarket));
        tradingEngine = new TradingEngine(address(futuresMarket), address(orderBook));
        liquidityPool = new LiquidityPool(address(futuresMarket));
        
        console.log("Exchange Infrastructure: DEPLOYED");
    }
    
    function initializeExchange() internal {
        console.log("\n--- Initializing Exchange ---");
        
        // Connect systems
        orderBook.initialize();
        listingManager.initialize();
        tradingEngine.initialize();
        liquidityPool.initialize();
        
        exchangeActive = true;
        
        console.log("Exchange: INITIALIZED");
    }
    
    function listInitialFutures() internal {
        console.log("\n--- Listing Initial Futures ---");
        
        string[] memory projects = new string[](8);
        projects[0] = "GridChain Infrastructure";
        projects[1] = "VINO Liquidity Pool";
        projects[2] = "Dragon Platform Development";
        projects[3] = "Arbitrage Bot Network";
        projects[4] = "Cross-Chain Bridge";
        projects[5] = "DeFi Insurance Fund";
        projects[6] = "MEV Optimization";
        projects[7] = "Flash Loan Aggregator";
        
        for (uint i = 0; i < projects.length; i++) {
            uint256 futureId = createAndListFuture(projects[i], i);
            listedFutures.push(futureId);
            totalFutures++;
        }
        
        console.log("Initial Futures: LISTED");
    }
    
    function createAndListFuture(string memory projectName, uint256 index) internal returns (uint256) {
        // Create future
        uint256 targetAmount = 100 ether * (index + 1);
        uint256 durationBlocks = 1000 * (index + 1);
        uint256 equityRate = 500 + (index * 100);
        uint256 burnRate = 100 + (index * 50);
        uint256 reinvestRate = 200 + (index * 100);
        
        uint256 futureId = futuresMarket.createTemporalFuture(
            projectName,
            string(abi.encodePacked("Decentralized infrastructure for ", projectName)),
            address(0xF6c369eEACC48CADeC353D6Aa3eD991cE1767a35),
            targetAmount,
            durationBlocks,
            equityRate,
            burnRate,
            reinvestRate
        );
        
        // List on exchange
        listingManager.listFuture(
            futureId,
            projectName,
            targetAmount,
            index % 2 == 0, // Every other one featured
            index < 4 ? "Infrastructure" : "DeFi"
        );
        
        isListed[futureId] = true;
        
        // Auto-invest seed capital
        futuresMarket.investInFuture{value: 1 ether}(futureId, 1 ether);
        
        console.log("Listed:", projectName, "ID:", futureId);
        
        return futureId;
    }
    
    function activateTrading() internal {
        console.log("\n--- Activating Trading ---");
        
        // Activate temporal engine for arbitrage
        temporalEngine.activate();
        
        // Set up trading pairs
        for (uint i = 0; i < listedFutures.length; i++) {
            tradingEngine.createTradingPair(listedFutures[i]);
        }
        
        // Start price feeds
        startPriceFeeds();
        
        console.log("Trading: ACTIVATED");
    }
    
    function startPriceFeeds() internal {
        // This would integrate with real price feeds
        // For now, simulate price updates
        for (uint i = 0; i < listedFutures.length; i++) {
            listingManager.updatePrice(listedFutures[i], 1 ether + (i * 0.1 ether));
        }
    }
    
    // Exchange functions for users
    function buyFutureToken(uint256 futureId, uint256 amount) external payable {
        require(isListed[futureId], "Future not listed");
        require(msg.value >= amount, "Insufficient payment");
        
        // Execute through trading engine
        tradingEngine.executeBuy(futureId, msg.sender, amount, msg.value);
        
        // Update volume
        totalVolume += amount;
        
        // Take exchange fee
        uint256 fee = (amount * exchangeFeeRate) / 10000;
        if (fee > 0) {
            (bool success, ) = payable(address(this)).call{value: fee}("");
            require(success, "Transfer failed");
        }
    }
    
    function sellFutureToken(uint256 futureId, uint256 amount) external {
        require(isListed[futureId], "Future not listed");
        
        // Execute through trading engine
        tradingEngine.executeSell(futureId, msg.sender, amount);
        
        // Update volume
        totalVolume += amount;
    }
    
    function getExchangeInfo() external view returns (
        uint256 _totalFutures,
        uint256 _totalVolume,
        bool _exchangeActive,
        uint256 _exchangeFeeRate
    ) {
        return (totalFutures, totalVolume, exchangeActive, exchangeFeeRate);
    }
    
    function getListedFutures() external view returns (uint256[] memory) {
        return listedFutures;
    }
    
    function getListingInfo(uint256 futureId) external view returns (ListingInfo memory) {
        return listings[futureId];
    }
}

/**
 * @title OrderBook
 * @notice ORDERBOOK FOR TEMPORAL FUTURES TRADING
 */
contract OrderBook {
    TemporalEquityFutures public futuresMarket;
    
    struct Order {
        uint256 orderId;
        uint256 futureId;
        address trader;
        bool isBuy;
        uint256 amount;
        uint256 price;
        uint256 timestamp;
        bool active;
    }
    
    mapping(uint256 => Order) public orders;
    mapping(uint256 => uint256[]) public buyOrders;
    mapping(uint256 => uint256[]) public sellOrders;
    mapping(address => uint256[]) public traderOrders;
    
    uint256 public nextOrderId;
    uint256 public totalOrders;
    
    event OrderPlaced(uint256 indexed orderId, uint256 futureId, address indexed trader, bool isBuy, uint256 amount, uint256 price);
    event OrderCancelled(uint256 indexed orderId);
    event OrderFilled(uint256 indexed orderId, address indexed filler, uint256 amount);
    
    constructor(address _futuresMarket) {
        futuresMarket = TemporalEquityFutures(_futuresMarket);
    }
    
    function initialize() external {
        // Initialize orderbook
    }
    
    function placeOrder(uint256 futureId, bool isBuy, uint256 amount, uint256 price) external returns (uint256) {
        uint256 orderId = nextOrderId++;
        
        orders[orderId] = Order({
            orderId: orderId,
            futureId: futureId,
            trader: msg.sender,
            isBuy: isBuy,
            amount: amount,
            price: price,
            timestamp: block.timestamp,
            active: true
        });
        
        if (isBuy) {
            buyOrders[futureId].push(orderId);
        } else {
            sellOrders[futureId].push(orderId);
        }
        
        traderOrders[msg.sender].push(orderId);
        totalOrders++;
        
        emit OrderPlaced(orderId, futureId, msg.sender, isBuy, amount, price);
        
        // Try to match immediately
        tryMatchOrders(futureId);
        
        return orderId;
    }
    
    function cancelOrder(uint256 orderId) external {
        Order storage order = orders[orderId];
        require(order.trader == msg.sender, "Not your order");
        require(order.active, "Order already filled");
        
        order.active = false;
        emit OrderCancelled(orderId);
    }
    
    function tryMatchOrders(uint256 futureId) internal {
        // Simple matching logic
        uint256[] memory buys = buyOrders[futureId];
        uint256[] memory sells = sellOrders[futureId];
        
        for (uint i = 0; i < buys.length; i++) {
            for (uint j = 0; j < sells.length; j++) {
                Order storage buyOrder = orders[buys[i]];
                Order storage sellOrder = orders[sells[j]];
                
                if (buyOrder.active && sellOrder.active && buyOrder.price >= sellOrder.price) {
                    // Match orders
                    uint256 tradeAmount = buyOrder.amount < sellOrder.amount ? buyOrder.amount : sellOrder.amount;
                    
                    // Execute trade
                    executeTrade(buyOrder, sellOrder, tradeAmount);
                    
                    // Update orders
                    buyOrder.amount -= tradeAmount;
                    sellOrder.amount -= tradeAmount;
                    
                    if (buyOrder.amount == 0) buyOrder.active = false;
                    if (sellOrder.amount == 0) sellOrder.active = false;
                    
                    emit OrderFilled(buyOrder.orderId, sellOrder.trader, tradeAmount);
                    emit OrderFilled(sellOrder.orderId, buyOrder.trader, tradeAmount);
                }
            }
        }
    }
    
    function executeTrade(Order storage buyOrder, Order storage sellOrder, uint256 amount) internal {
        // Transfer tokens and ETH
        address futureToken = futuresMarket.futureTokens(buyOrder.futureId);
        
        // Buyer receives tokens, seller receives ETH
        (bool success, ) = payable(sellOrder.trader).call{value: amount * sellOrder.price / 1e18}("");
        require(success, "Transfer failed");
        // Token transfer would be done via TemporalEquityToken contract
    }
}

/**
 * @title ListingManager
 * @notice MANAGES FUTURES LISTINGS ON EXCHANGE
 */
contract ListingManager {
    TemporalEquityFutures public futuresMarket;
    
    mapping(uint256 => bool) public isListed;
    uint256[] public allListings;
    
    uint256 public nextListingId;
    uint256 public listingFee = 1 ether;
    
    event FutureListed(uint256 indexed futureId, string projectName, uint256 listingPrice);
    event PriceUpdated(uint256 indexed futureId, uint256 newPrice, uint256 oldPrice);
    event FeaturedUpdated(uint256 indexed futureId, bool featured);
    
    constructor(address _futuresMarket) {
        futuresMarket = TemporalEquityFutures(_futuresMarket);
    }
    
    function initialize() external {
        // Initialize listing manager
    }
    
    function listFuture(
        uint256 futureId,
        string memory projectName,
        uint256 targetAmount,
        bool featured,
        string memory category
    ) external payable {
        require(msg.value >= listingFee, "Insufficient listing fee");
        require(!isListed[futureId], "Already listed");
        
        // Store listing info in parent contract
        // TemporalFuturesExchange(address(this)).storeListingInfo(futureId, projectName, targetAmount, featured, category);
        
        isListed[futureId] = true;
        allListings.push(futureId);
        
        emit FutureListed(futureId, projectName, targetAmount);
    }
    
    function updatePrice(uint256 futureId, uint256 newPrice) external {
        require(isListed[futureId], "Not listed");
        
        // Price update logic would be handled by parent contract
        emit PriceUpdated(futureId, newPrice, 0);
    }
    
    function getTopListings(uint256 count) external view returns (uint256[] memory) {
        uint256[] memory topListings = new uint256[](count);
        
        // Simple logic: return first 'count' listings
        for (uint i = 0; i < count && i < allListings.length; i++) {
            topListings[i] = allListings[i];
        }
        
        return topListings;
    }
}

/**
 * @title TradingEngine
 * @notice EXECUTES TRADES ON EXCHANGE
 */
contract TradingEngine {
    TemporalEquityFutures public futuresMarket;
    OrderBook public orderBook;
    
    mapping(uint256 => bool) public hasTradingPair;
    mapping(uint256 => uint256) public currentPrice;
    
    event TradeExecuted(uint256 indexed futureId, address indexed buyer, address indexed seller, uint256 amount, uint256 price);
    
    constructor(address _futuresMarket, address _orderBook) {
        futuresMarket = TemporalEquityFutures(_futuresMarket);
        orderBook = OrderBook(_orderBook);
    }
    
    function initialize() external {
        // Initialize trading engine
    }
    
    function createTradingPair(uint256 futureId) external {
        hasTradingPair[futureId] = true;
        currentPrice[futureId] = 1 ether; // Initial price
    }
    
    function executeBuy(uint256 futureId, address buyer, uint256 amount, uint256 ethAmount) external {
        require(hasTradingPair[futureId], "No trading pair");
        
        // Place buy order
        uint256 price = ethAmount * 1e18 / amount;
        orderBook.placeOrder(futureId, true, amount, price);
        
        emit TradeExecuted(futureId, buyer, address(0), amount, price);
    }
    
    function executeSell(uint256 futureId, address seller, uint256 amount) external {
        require(hasTradingPair[futureId], "No trading pair");
        
        // Place sell order at current market price
        orderBook.placeOrder(futureId, false, amount, currentPrice[futureId]);
        
        emit TradeExecuted(futureId, address(0), seller, amount, currentPrice[futureId]);
    }
}

/**
 * @title LiquidityPool
 * @notice PROVIDES LIQUIDITY FOR TEMPORAL FUTURES TRADING
 */
contract LiquidityPool {
    TemporalEquityFutures public futuresMarket;
    
    mapping(uint256 => uint256) public poolLiquidity;
    mapping(uint256 => mapping(address => uint256)) public providerShares;
    mapping(uint256 => uint256) public totalShares;
    
    event LiquidityAdded(uint256 indexed futureId, address indexed provider, uint256 amount);
    event LiquidityRemoved(uint256 indexed futureId, address indexed provider, uint256 amount);
    
    constructor(address _futuresMarket) {
        futuresMarket = TemporalEquityFutures(_futuresMarket);
    }
    
    function initialize() external {
        // Initialize liquidity pool
    }
    
    function addLiquidity(uint256 futureId) external payable {
        require(msg.value > 0, "No liquidity provided");
        
        poolLiquidity[futureId] += msg.value;
        
        // Calculate shares
        uint256 shares = msg.value;
        if (totalShares[futureId] > 0) {
            shares = (msg.value * totalShares[futureId]) / poolLiquidity[futureId];
        }
        
        providerShares[futureId][msg.sender] += shares;
        totalShares[futureId] += shares;
        
        emit LiquidityAdded(futureId, msg.sender, msg.value);
    }
    
    function removeLiquidity(uint256 futureId, uint256 shares) external {
        require(providerShares[futureId][msg.sender] >= shares, "Insufficient shares");
        
        uint256 liquidityAmount = (shares * poolLiquidity[futureId]) / totalShares[futureId];
        
        providerShares[futureId][msg.sender] -= shares;
        totalShares[futureId] -= shares;
        poolLiquidity[futureId] -= liquidityAmount;
        
        (bool success, ) = payable(msg.sender).call{value: liquidityAmount}("");
        require(success, "Transfer failed");
        
        emit LiquidityRemoved(futureId, msg.sender, liquidityAmount);
    }
}
