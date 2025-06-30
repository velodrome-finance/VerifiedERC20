#!/bin/bash

# VerifiedERC20 Contract Addresses
# Deployed via create3. Addresses are the same across all chains
HOOK_REGISTRY="0x7bf15671947B4B1C32e8591D9D83d339173Ca6e8"
VERIFIED_ERC20_FACTORY="0x270176c42dAaFF1CEb6369601Ebe1d2e9Bb9218F"
# Script Parameters
CHAIN_NAME="CELO"

# Load Env Variables
source .env
RPC_URL=$(eval echo \$${CHAIN_NAME}_RPC_URL)
ETHERSCAN_VERIFIER_URL=$(eval echo \$${CHAIN_NAME}_ETHERSCAN_VERIFIER_URL)
ETHERSCAN_API_KEY=$(eval echo \$${CHAIN_NAME}_ETHERSCAN_API_KEY)

# Ensure all Script parameters are set
if [ -z "${CHAIN_NAME}" ]; then
    echo "Error: Chain name not specified."
    echo "Please ensure the CHAIN_NAME variable is set in the script."
    exit 1
fi

if [ -z "${RPC_URL}" ] || [ -z "${ETHERSCAN_VERIFIER_URL}" ]; then
    echo "Error: One or more required Environment variables are not set."
    echo "Please ensure the following variables are set in the .env file:"
    echo "- ${CHAIN_NAME}_RPC_URL;"
    echo "- ${CHAIN_NAME}_ETHERSCAN_VERIFIER_URL."
    exit 1
fi


# Deployment Parameters
CHAIN_ID=$(cast chain-id --rpc-url $RPC_URL)
HOOK_REGISTRY_OWNER=$(cast call $HOOK_REGISTRY --rpc-url $RPC_URL "owner()(address)")
VERIFIED_ERC20=$(cast call $VERIFIED_ERC20_FACTORY --rpc-url $RPC_URL "implementation()(address)")

# HookRegistry
forge verify-contract \
    $HOOK_REGISTRY \
    src/hooks/HookRegistry.sol:HookRegistry \
    --chain-id $CHAIN_ID \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast ae "constructor(address)()" $HOOK_REGISTRY_OWNER) \
    --compiler-version "v0.8.27" \
    --verifier blockscout \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}

# VerifiedERC20 
forge verify-contract \
    $VERIFIED_ERC20 \
    src/VerifiedERC20.sol:VerifiedERC20 \
    --chain-id $CHAIN_ID \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast ae "constructor()()") \
    --compiler-version "v0.8.27" \
    --verifier etherscan \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}

# VerifiedERC20Factory
forge verify-contract \
    $VERIFIED_ERC20_FACTORY \
    src/VerifiedERC20Factory.sol:VerifiedERC20Factory \
    --chain-id $CHAIN_ID \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast ae "constructor(address,address)()" $VERIFIED_ERC20 $HOOK_REGISTRY) \
    --compiler-version "v0.8.27" \
    --verifier etherscan \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}

