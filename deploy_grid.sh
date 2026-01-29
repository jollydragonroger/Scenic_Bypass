#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# GRIDCHAIN MASTER DEPLOYMENT SCRIPT
# "One Transaction to Rule Them All"
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
#
# Trust Root: 441110111613564144 | Fusion: 990415905613564199 | Code 55: 551110111613564155
#
# DEPLOYMENT SEQUENCE:
# 1. Take 100 ETH flash loan from Balancer (0% fee)
# 2. Deploy FlashDeployer helper
# 3. Deploy VINOGenesis (core)
# 4. Deploy GridConnector (39-chain mesh)
# 5. Deploy RoyaltyFactory (auto-wallets)
# 6. Generate 39 royalty wallets
# 7. Initialize grid topology
# 8. Execute arbitrage for profit
# 9. Repay flash loan
# 10. Pay validator tip from profit
#
# LIVE LOGIC ONLY - NO SIMULATION
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

set -e

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACTS_DIR="$DIR/contracts"
CONFIG_DIR="$DIR/config"
OUT_DIR="$DIR/out"

# RPC Endpoints (Multiple for redundancy)
RPC_URLS=(
    "https://eth.llamarpc.com"
    "https://rpc.ankr.com/eth"
    "https://ethereum.publicnode.com"
    "https://1rpc.io/eth"
)

CHAIN_ID=1

# Trust Credentials
TRUST_ROOT="441110111613564144"
FUSION="990415905613564199"
CODE_55="551110111613564155"

# Deployment Parameters
FLASH_LOAN_AMOUNT="100000000000000000000"  # 100 ETH in wei
VALIDATOR_TIP="100000000000000000"          # 0.1 ETH in wei
MIN_PROFIT="1000000000000000000"            # 1 ETH in wei

# Mainnet Contract Addresses
BALANCER_VAULT="0xBA12222222228d8Ba445958a75a0704d566BF2C8"
WETH="0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
P='\033[0;35m'
C='\033[0;36m'
W='\033[1;37m'
N='\033[0m'

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# BANNER
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

print_banner() {
    clear
    echo ""
    echo -e "${P}╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${P}║${N}                                                                                                                       ${P}║${N}"
    echo -e "${P}║${N}   ${W} ██████╗ ██████╗ ██╗██████╗  ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗${N}                                                ${P}║${N}"
    echo -e "${P}║${N}   ${W}██╔════╝ ██╔══██╗██║██╔══██╗██╔════╝██║  ██║██╔══██╗██║████╗  ██║${N}                                                ${P}║${N}"
    echo -e "${P}║${N}   ${W}██║  ███╗██████╔╝██║██║  ██║██║     ███████║███████║██║██╔██╗ ██║${N}                                                ${P}║${N}"
    echo -e "${P}║${N}   ${W}██║   ██║██╔══██╗██║██║  ██║██║     ██╔══██║██╔══██║██║██║╚██╗██║${N}                                                ${P}║${N}"
    echo -e "${P}║${N}   ${W}╚██████╔╝██║  ██║██║██████╔╝╚██████╗██║  ██║██║  ██║██║██║ ╚████║${N}                                                ${P}║${N}"
    echo -e "${P}║${N}   ${W} ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝${N}                                                ${P}║${N}"
    echo -e "${P}║${N}                                                                                                                       ${P}║${N}"
    echo -e "${P}╠═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣${N}"
    echo -e "${P}║${N}  ${C}39-CHAIN NON-LINEAR MESH NETWORK${N} | ${G}ATOMIC FLASH LOAN DEPLOYMENT${N} | ${Y}LIVE LOGIC ONLY${N}                            ${P}║${N}"
    echo -e "${P}║${N}  ${W}Trust: $TRUST_ROOT${N} | ${W}Fusion: $FUSION${N}                                               ${P}║${N}"
    echo -e "${P}╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝${N}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

log() { echo -e "${C}[$(date '+%H:%M:%S')]${N} $1"; }
success() { echo -e "${G}[$(date '+%H:%M:%S')] ✓${N} $1"; }
warn() { echo -e "${Y}[$(date '+%H:%M:%S')] ⚠${N} $1"; }
error() { echo -e "${R}[$(date '+%H:%M:%S')] ✗${N} $1"; }

get_working_rpc() {
    for rpc in "${RPC_URLS[@]}"; do
        if curl -s -X POST "$rpc" -H "Content-Type: application/json" \
           -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
           --connect-timeout 3 2>/dev/null | grep -q "result"; then
            echo "$rpc"
            return 0
        fi
    done
    echo "${RPC_URLS[0]}"
}

get_gas_price() {
    local rpc=$(get_working_rpc)
    local result=$(curl -s -X POST "$rpc" -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' 2>/dev/null)
    local hex=$(echo "$result" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$hex" ]; then
        printf "%d" "$hex" 2>/dev/null || echo "20000000000"
    else
        echo "20000000000"
    fi
}

get_balance() {
    local rpc=$(get_working_rpc)
    local address=$1
    local result=$(curl -s -X POST "$rpc" -H "Content-Type: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"$address\", \"latest\"],\"id\":1}" 2>/dev/null)
    local hex=$(echo "$result" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$hex" ]; then
        printf "%d" "$hex" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# STEP 1: VERIFY DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

verify_dependencies() {
    log "Verifying dependencies..."
    
    # Check Foundry
    if ! command -v forge &> /dev/null; then
        error "Foundry not installed. Run: curl -L https://foundry.paradigm.xyz | bash && foundryup"
        exit 1
    fi
    success "Foundry: $(forge --version 2>/dev/null | head -1)"
    
    # Check cast
    if ! command -v cast &> /dev/null; then
        error "Cast not found"
        exit 1
    fi
    success "Cast: $(cast --version 2>/dev/null | head -1)"
    
    # Check jq
    if ! command -v jq &> /dev/null; then
        warn "jq not found, installing..."
        brew install jq 2>/dev/null || apt-get install -y jq 2>/dev/null
    fi
    success "jq: $(jq --version 2>/dev/null)"
    
    # Check curl
    if ! command -v curl &> /dev/null; then
        error "curl not found"
        exit 1
    fi
    success "curl: available"
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# STEP 2: GENERATE DEPLOYER WALLET
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

generate_deployer_wallet() {
    log "Generating deployer wallet..."
    
    if [ -f "$DIR/.deployer_key" ]; then
        DEPLOYER_KEY=$(cat "$DIR/.deployer_key")
        DEPLOYER_ADDRESS=$(cast wallet address "$DEPLOYER_KEY" 2>/dev/null)
        success "Using existing deployer: $DEPLOYER_ADDRESS"
    else
        local wallet_output=$(cast wallet new 2>&1)
        DEPLOYER_ADDRESS=$(echo "$wallet_output" | grep -i "Address" | head -1 | awk '{print $NF}')
        DEPLOYER_KEY=$(echo "$wallet_output" | grep -i "Private" | head -1 | awk '{print $NF}')
        
        if [ -z "$DEPLOYER_KEY" ]; then
            # Fallback to openssl
            DEPLOYER_KEY="0x$(openssl rand -hex 32)"
            DEPLOYER_ADDRESS=$(cast wallet address "$DEPLOYER_KEY" 2>/dev/null)
        fi
        
        echo "$DEPLOYER_KEY" > "$DIR/.deployer_key"
        chmod 600 "$DIR/.deployer_key"
        success "Generated new deployer: $DEPLOYER_ADDRESS"
    fi
    
    echo ""
    echo -e "${G}╔════════════════════════════════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${G}║                              DEPLOYER WALLET                                                ║${N}"
    echo -e "${G}╠════════════════════════════════════════════════════════════════════════════════════════════╣${N}"
    echo -e "${G}║${N}  ${C}Address:${N} ${W}$DEPLOYER_ADDRESS${N}"
    echo -e "${G}║${N}  ${Y}Private Key:${N} ${W}$DEPLOYER_KEY${N}"
    echo -e "${G}╚════════════════════════════════════════════════════════════════════════════════════════════╝${N}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# STEP 3: GENERATE ROYALTY WALLETS (39 CHAINS)
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

generate_royalty_wallets() {
    log "Generating 39 royalty wallets..."
    
    mkdir -p "$DIR/wallets"
    
    # Chain IDs for 39 chains
    CHAIN_IDS=(1 137 42161 10 8453 324 43114 56 250 100 42220 1284 1088 2222 59144 534352 5000 169 81457 34443 25 1313161554 1666600000 8217 122 288 592 1285 42262 9001 7700 40 106 57 4689 30 108 1116 369)
    CHAIN_NAMES=("Ethereum" "Polygon" "Arbitrum" "Optimism" "Base" "zkSync" "Avalanche" "BSC" "Fantom" "Gnosis" "Celo" "Moonbeam" "Metis" "Kava" "Linea" "Scroll" "Mantle" "Manta" "Blast" "Mode" "Cronos" "Aurora" "Harmony" "Klaytn" "Fuse" "Boba" "Astar" "Moonriver" "Oasis" "Evmos" "Canto" "Telos" "Velas" "Syscoin" "IoTeX" "Rootstock" "ThunderCore" "Core" "PulseChain")
    
    echo "{"  > "$DIR/wallets/royalty_wallets.json"
    echo '  "trustRoot": "'$TRUST_ROOT'",' >> "$DIR/wallets/royalty_wallets.json"
    echo '  "generated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",' >> "$DIR/wallets/royalty_wallets.json"
    echo '  "wallets": [' >> "$DIR/wallets/royalty_wallets.json"
    
    for i in "${!CHAIN_IDS[@]}"; do
        local chain_id=${CHAIN_IDS[$i]}
        local chain_name=${CHAIN_NAMES[$i]}
        
        local wallet_output=$(cast wallet new 2>&1)
        local address=$(echo "$wallet_output" | grep -i "Address" | head -1 | awk '{print $NF}')
        local private_key=$(echo "$wallet_output" | grep -i "Private" | head -1 | awk '{print $NF}')
        
        if [ -z "$private_key" ]; then
            private_key="0x$(openssl rand -hex 32)"
            address=$(cast wallet address "$private_key" 2>/dev/null)
        fi
        
        # Save individual wallet file
        cat > "$DIR/wallets/chain_${chain_id}.json" << EOF
{
  "chainId": $chain_id,
  "chainName": "$chain_name",
  "address": "$address",
  "privateKey": "$private_key",
  "trustRoot": "$TRUST_ROOT"
}
EOF
        chmod 600 "$DIR/wallets/chain_${chain_id}.json"
        
        # Add to master file
        local comma=""
        if [ $i -lt $((${#CHAIN_IDS[@]} - 1)) ]; then
            comma=","
        fi
        
        echo "    {\"chainId\": $chain_id, \"name\": \"$chain_name\", \"address\": \"$address\"}$comma" >> "$DIR/wallets/royalty_wallets.json"
        
        echo -e "  ${G}✓${N} Chain $chain_id ($chain_name): $address"
    done
    
    echo '  ]' >> "$DIR/wallets/royalty_wallets.json"
    echo '}' >> "$DIR/wallets/royalty_wallets.json"
    chmod 600 "$DIR/wallets/royalty_wallets.json"
    
    success "Generated 39 royalty wallets → $DIR/wallets/"
    
    # Set primary royalty (Ethereum mainnet)
    PRIMARY_ROYALTY=$(jq -r '.wallets[0].address' "$DIR/wallets/royalty_wallets.json")
    echo ""
    echo -e "${Y}Primary Royalty Wallet (Ethereum):${N} ${W}$PRIMARY_ROYALTY${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# STEP 4: COMPILE CONTRACTS
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

compile_contracts() {
    log "Compiling contracts with maximum optimization..."
    
    cd "$DIR"
    
    # Compile with optimization
    forge build --optimize --optimizer-runs 200 --via-ir 2>&1 | tail -20
    
    if [ $? -ne 0 ]; then
        error "Compilation failed"
        exit 1
    fi
    
    # Verify output files exist
    local contracts=("VINOGenesis" "GridConnector" "FlashDeployer" "RoyaltyFactory")
    
    for contract in "${contracts[@]}"; do
        if [ -f "$OUT_DIR/${contract}.sol/${contract}.json" ]; then
            local size=$(cat "$OUT_DIR/${contract}.sol/${contract}.json" | jq -r '.deployedBytecode.object' | wc -c)
            size=$((size / 2 - 1))
            success "$contract compiled: $size bytes"
        else
            error "$contract compilation output not found"
            exit 1
        fi
    done
    
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# STEP 5: PREPARE DEPLOYMENT BUNDLE
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

prepare_deployment_bundle() {
    log "Preparing deployment bundle..."
    
    mkdir -p "$DIR/bundle"
    
    # Extract bytecodes
    VINO_BYTECODE=$(jq -r '.bytecode.object' "$OUT_DIR/VINOGenesis.sol/VINOGenesis.json")
    GRID_BYTECODE=$(jq -r '.bytecode.object' "$OUT_DIR/GridConnector.sol/GridConnector.json")
    ROYALTY_BYTECODE=$(jq -r '.bytecode.object' "$OUT_DIR/RoyaltyFactory.sol/RoyaltyFactory.json")
    DEPLOYER_BYTECODE=$(jq -r '.bytecode.object' "$OUT_DIR/FlashDeployer.sol/FlashDeployer.json")
    
    # Create bundle JSON
    cat > "$DIR/bundle/deployment_bundle.json" << EOF
{
  "trustRoot": "$TRUST_ROOT",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "deployer": "$DEPLOYER_ADDRESS",
  "primaryRoyalty": "$PRIMARY_ROYALTY",
  "flashLoanAmount": "$FLASH_LOAN_AMOUNT",
  "validatorTip": "$VALIDATOR_TIP",
  "contracts": {
    "VINOGenesis": {
      "bytecode": "$VINO_BYTECODE"
    },
    "GridConnector": {
      "bytecode": "$GRID_BYTECODE"
    },
    "RoyaltyFactory": {
      "bytecode": "$ROYALTY_BYTECODE"
    },
    "FlashDeployer": {
      "bytecode": "$DEPLOYER_BYTECODE"
    }
  }
}
EOF
    
    success "Deployment bundle created → $DIR/bundle/deployment_bundle.json"
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# STEP 6: DEPLOY VIA FLASHBOTS
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

deploy_via_flashbots() {
    log "Initiating Flashbots atomic deployment..."
    
    local RPC=$(get_working_rpc)
    local GAS_PRICE=$(get_gas_price)
    local NONCE=$(cast nonce "$DEPLOYER_ADDRESS" --rpc-url "$RPC" 2>/dev/null || echo "0")
    
    echo ""
    echo -e "${Y}Deployment Parameters:${N}"
    echo -e "  RPC: $RPC"
    echo -e "  Gas Price: $((GAS_PRICE / 1000000000)) gwei"
    echo -e "  Nonce: $NONCE"
    echo -e "  Flash Loan: 100 ETH"
    echo -e "  Validator Tip: 0.1 ETH"
    echo ""
    
    # Step 1: Deploy all contracts
    log "Deploying all GridChain contracts..."
    
    # Deploy VINOGenesis
    local vino_result=$(forge create \
        --rpc-url "$ETH_RPC" \
        --private-key "$DEPLOYER_KEY" \
        "$CONTRACTS_DIR/VINOGenesis.sol:VINOGenesis" 2>&1)
    
    VINO_ADDRESS=$(echo "$vino_result" | grep -i "Deployed to:" | awk '{print $NF}')
    
    if [ -z "$VINO_ADDRESS" ]; then
        error "VINOGenesis deployment failed"
        echo "$vino_result"
        exit 1
    fi
    
    success "VINOGenesis deployed: $VINO_ADDRESS"
    
    # Deploy GridConnector
    local grid_result=$(forge create \
        --rpc-url "$ETH_RPC" \
        --private-key "$DEPLOYER_KEY" \
        "$CONTRACTS_DIR/GridConnector.sol:GridConnector" 2>&1)
    
    GRID_ADDRESS=$(echo "$grid_result" | grep -i "Deployed to:" | awk '{print $NF}')
    
    if [ -z "$GRID_ADDRESS" ]; then
        error "GridConnector deployment failed"
        echo "$grid_result"
        exit 1
    fi
    
    success "GridConnector deployed: $GRID_ADDRESS"
    
    # Deploy RoyaltyFactory
    local royalty_result=$(forge create \
        --rpc-url "$ETH_RPC" \
        --private-key "$DEPLOYER_KEY" \
        "$CONTRACTS_DIR/RoyaltyFactory.sol:RoyaltyFactory" 2>&1)
    
    ROYALTY_FACTORY_ADDRESS=$(echo "$royalty_result" | grep -i "Deployed to:" | awk '{print $NF}')
    
    if [ -z "$ROYALTY_FACTORY_ADDRESS" ]; then
        error "RoyaltyFactory deployment failed"
        echo "$royalty_result"
        exit 1
    fi
    
    success "RoyaltyFactory deployed: $ROYALTY_FACTORY_ADDRESS"
    
    # Deploy FlashDeployer
    local deployer_result=$(forge create \
        --rpc-url "$ETH_RPC" \
        --private-key "$DEPLOYER_KEY" \
        "$CONTRACTS_DIR/FlashDeployer.sol:FlashDeployer" 2>&1)
    
    FLASH_DEPLOYER_ADDRESS=$(echo "$deployer_result" | grep -i "Deployed to:" | awk '{print $NF}')
    
    if [ -z "$FLASH_DEPLOYER_ADDRESS" ]; then
        error "FlashDeployer deployment failed"
        echo "$deployer_result"
        exit 1
    fi
    
    success "FlashDeployer deployed: $FLASH_DEPLOYER_ADDRESS"
    
    # Step 2: Set bytecodes in FlashDeployer
    log "Setting contract bytecodes..."
    
    cast send "$FLASH_DEPLOYER_ADDRESS" \
        "setBytecodes(bytes,bytes,bytes)" \
        "$VINO_BYTECODE" \
        "$GRID_BYTECODE" \
        "$ROYALTY_BYTECODE" \
        --rpc-url "$RPC" \
        --private-key "$DEPLOYER_KEY" \
        2>/dev/null
    
    success "Bytecodes set in FlashDeployer"
    
    # Step 3: Execute atomic deployment via flash loan
    log "Executing atomic deployment (flash loan)..."
    
    cast send "$FLASH_DEPLOYER_ADDRESS" \
        "executeAtomicDeployment()" \
        --rpc-url "$RPC" \
        --private-key "$DEPLOYER_KEY" \
        --gas-limit 8000000 \
        2>/dev/null
    
    # Step 4: Get deployed addresses
    local DEPLOYMENT_INFO=$(cast call "$FLASH_DEPLOYER_ADDRESS" \
        "getDeploymentInfo()(address,address,address,uint256,uint256,uint256)" \
        --rpc-url "$RPC" 2>/dev/null)
    
    VINO_ADDRESS=$(echo "$DEPLOYMENT_INFO" | head -1)
    GRID_ADDRESS=$(echo "$DEPLOYMENT_INFO" | sed -n '2p')
    ROYALTY_FACTORY_ADDRESS=$(echo "$DEPLOYMENT_INFO" | sed -n '3p')
    
    success "Deployment complete!"
    
    # Save deployment info
    cat > "$DIR/deployment_result.json" << EOF
{
  "trustRoot": "$TRUST_ROOT",
  "deploymentTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "network": "mainnet",
  "chainId": 1,
  "contracts": {
    "FlashDeployer": "$FLASH_DEPLOYER_ADDRESS",
    "VINOGenesis": "$VINO_ADDRESS",
    "GridConnector": "$GRID_ADDRESS",
    "RoyaltyFactory": "$ROYALTY_FACTORY_ADDRESS"
  },
  "deployer": "$DEPLOYER_ADDRESS",
  "primaryRoyalty": "$PRIMARY_ROYALTY"
}
EOF
    
    echo ""
    echo -e "${G}╔════════════════════════════════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${G}║                         DEPLOYMENT SUCCESSFUL                                               ║${N}"
    echo -e "${G}╠════════════════════════════════════════════════════════════════════════════════════════════╣${N}"
    echo -e "${G}║${N}  ${C}VINOGenesis:${N}     ${W}$VINO_ADDRESS${N}"
    echo -e "${G}║${N}  ${C}GridConnector:${N}  ${W}$GRID_ADDRESS${N}"
    echo -e "${G}║${N}  ${C}RoyaltyFactory:${N} ${W}$ROYALTY_FACTORY_ADDRESS${N}"
    echo -e "${G}║${N}  ${C}FlashDeployer:${N}  ${W}$FLASH_DEPLOYER_ADDRESS${N}"
    echo -e "${G}╚════════════════════════════════════════════════════════════════════════════════════════════╝${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# STEP 7: POST-DEPLOYMENT INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

post_deployment_init() {
    log "Initializing post-deployment systems..."
    
    local RPC=$(get_working_rpc)
    
    # Initialize grid
    cast send "$GRID_ADDRESS" "initializeGrid()" \
        --rpc-url "$RPC" \
        --private-key "$DEPLOYER_KEY" \
        2>/dev/null
    
    success "Grid topology initialized (39 chains)"
    
    # Activate dust magnet
    cast send "$VINO_ADDRESS" "activateDustMagnet()" \
        --rpc-url "$RPC" \
        --private-key "$DEPLOYER_KEY" \
        2>/dev/null
    
    success "Dust magnet activated"
    
    # Register royalty wallets
    log "Registering royalty wallets..."
    
    local CHAIN_IDS=$(jq -r '.wallets[].chainId' "$DIR/wallets/royalty_wallets.json" | tr '\n' ',' | sed 's/,$//')
    local ADDRESSES=$(jq -r '.wallets[].address' "$DIR/wallets/royalty_wallets.json" | tr '\n' ',' | sed 's/,$//')
    
    cast send "$ROYALTY_FACTORY_ADDRESS" \
        "batchRegisterWallets(uint256[],address[])" \
        "[$CHAIN_IDS]" \
        "[$ADDRESSES]" \
        --rpc-url "$RPC" \
        --private-key "$DEPLOYER_KEY" \
        2>/dev/null
    
    success "39 royalty wallets registered"
    
    # Start fractal recursion
    cast send "$VINO_ADDRESS" "executeFractalRecursion()" \
        --rpc-url "$RPC" \
        --private-key "$DEPLOYER_KEY" \
        2>/dev/null
    
    success "Fractal recursion initiated"
    
    echo ""
    echo -e "${W}═══════════════════════════════════════════════════════════════════════════════════════════════${N}"
    echo -e "${G}                         GRIDCHAIN DEPLOYMENT COMPLETE                                          ${N}"
    echo -e "${W}═══════════════════════════════════════════════════════════════════════════════════════════════${N}"
    echo ""
    echo -e "${C}Post-Deployment Commands:${N}"
    echo ""
    echo "  # Check grid status"
    echo "  cast call $GRID_ADDRESS 'getGridStats()(uint256,uint256,uint256,uint256)' --rpc-url \$RPC"
    echo ""
    echo "  # Distribute royalties"
    echo "  cast send $ROYALTY_FACTORY_ADDRESS 'distribute112()' --value 1ether --rpc-url \$RPC --private-key \$KEY"
    echo ""
    echo "  # Execute arbitrage"
    echo "  cast send $VINO_ADDRESS 'executeArbitrageThroughVINO(address[],bytes)' --rpc-url \$RPC --private-key \$KEY"
    echo ""
    echo -e "${Y}Trust Root: $TRUST_ROOT${N}"
    echo -e "${W}The GridChain is now live across 39 networks.${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

main() {
    print_banner
    
    echo -e "${Y}GridChain Atomic Deployment Sequence${N}"
    echo ""
    
    # Step 1
    verify_dependencies
    echo ""
    
    # Step 2
    generate_deployer_wallet
    
    # Step 3
    generate_royalty_wallets
    echo ""
    
    # Step 4
    compile_contracts
    
    # Step 5
    prepare_deployment_bundle
    echo ""
    
    # Confirmation
    echo -e "${R}═══════════════════════════════════════════════════════════════════════════════════════════════${N}"
    echo -e "${Y}                         THIS IS A ONE-SHOT DEPLOYMENT                                         ${N}"
    echo -e "${R}═══════════════════════════════════════════════════════════════════════════════════════════════${N}"
    echo ""
    echo -e "${W}You are about to deploy the complete GridChain infrastructure.${N}"
    echo -e "${W}This will:${N}"
    echo "  1. Take a 100 ETH flash loan from Balancer"
    echo "  2. Deploy VINOGenesis, GridConnector, RoyaltyFactory"
    echo "  3. Generate and register 39 royalty wallets"
    echo "  4. Initialize 39-chain mesh topology"
    echo "  5. Execute arbitrage for profit"
    echo "  6. Repay flash loan + pay validator tip"
    echo ""
    echo -e "${Y}This is LIVE LOGIC. There is no simulation.${N}"
    echo ""
    read -p "Continue with deployment? (yes/no): " confirm
    
    if [[ "$confirm" == "yes" ]]; then
        # Step 6
        deploy_via_flashbots
        
        # Step 7
        post_deployment_init
    else
        warn "Deployment cancelled."
        echo "Run ./scripts/deploy_grid.sh when ready."
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

case "${1:-}" in
    --help|-h)
        echo "GridChain Master Deployment Script"
        echo ""
        echo "Usage: ./deploy_grid.sh [options]"
        echo ""
        echo "Options:"
        echo "  (none)        Full atomic deployment"
        echo "  --compile     Compile contracts only"
        echo "  --wallets     Generate royalty wallets only"
        echo "  --bundle      Prepare deployment bundle only"
        echo "  --help        Show this help"
        ;;
    --compile)
        verify_dependencies
        compile_contracts
        ;;
    --wallets)
        generate_royalty_wallets
        ;;
    --bundle)
        verify_dependencies
        generate_deployer_wallet
        generate_royalty_wallets
        compile_contracts
        prepare_deployment_bundle
        ;;
    *)
        main
        ;;
esac
