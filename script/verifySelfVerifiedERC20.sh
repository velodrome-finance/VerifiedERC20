#!/bin/bash

# SelfVerifiedERC20 Contract Addresses
ERC20_LOCKBOX=""
SINGLE_PERMISSION_MINT_HOOK=""
SINGLE_PERMISSION_BURN_HOOK=""
SELF_TRANSFER_HOOK=""
AUTO_UNWRAP_HOOK=""
SELF_VERIFIED_ERC20=""

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
CELO=$(cast call $ERC20_LOCKBOX --rpc-url $RPC_URL "ERC20()(address)")
SINGLE_PERMISSION_MINT_HOOK_NAME=$(cast call $SINGLE_PERMISSION_MINT_HOOK --rpc-url $RPC_URL "name()(string)")
SINGLE_PERMISSION_BURN_HOOK_NAME=$(cast call $SINGLE_PERMISSION_BURN_HOOK --rpc-url $RPC_URL "name()(string)")
SELF_TRANSFER_HOOK_NAME=$(cast call $SELF_TRANSFER_HOOK --rpc-url $RPC_URL "name()(string)")
SELF_TRANSFER_HOOK_VOTER=$(cast call $SELF_TRANSFER_HOOK --rpc-url $RPC_URL "voter()(address)")
SELF_TRANSFER_HOOK_REWARDS_AUTHORIZED=$(cast call $SELF_TRANSFER_HOOK --rpc-url $RPC_URL "authorized()(address)")
SELF_PASSPORT_SBT=$(cast call $SELF_TRANSFER_HOOK --rpc-url $RPC_URL "selfPassportSBT()(address)")
AUTO_UNWRAP_HOOK_NAME=$(cast call $AUTO_UNWRAP_HOOK --rpc-url $RPC_URL "name()(string)")

# ERC20Lockbox 
forge verify-contract \
    $ERC20_LOCKBOX \
    src/external/ERC20Lockbox.sol:ERC20Lockbox \
    --chain-id $CHAIN_ID \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast ae "constructor(address,address)()" $SELF_VERIFIED_ERC20 $CELO) \
    --compiler-version "v0.8.27" \
    --verifier etherscan \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}

# SinglePermissionMintHook 
forge verify-contract \
    $SINGLE_PERMISSION_MINT_HOOK \
    src/hooks/extensions/SinglePermissionHook.sol:SinglePermissionHook \
    --chain-id $CHAIN_ID \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast ae "constructor(string,address[],address[])()" $SINGLE_PERMISSION_MINT_HOOK_NAME "[$SELF_VERIFIED_ERC20]" "[$ERC20_LOCKBOX]") \
    --compiler-version "v0.8.27" \
    --verifier etherscan \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}

# SinglePermissionBurnHook 
forge verify-contract \
    $SINGLE_PERMISSION_BURN_HOOK \
    src/hooks/extensions/SinglePermissionHook.sol:SinglePermissionHook \
    --chain-id $CHAIN_ID \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast ae "constructor(string,address[],address[])()" $SINGLE_PERMISSION_BURN_HOOK_NAME "[$SELF_VERIFIED_ERC20]" "[$ERC20_LOCKBOX]") \
    --compiler-version "v0.8.27" \
    --verifier etherscan \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}

# SelfTransferHook
forge verify-contract \
    $SELF_TRANSFER_HOOK \
    src/hooks/extensions/SelfTransferHook.sol:SelfTransferHook \
    --chain-id $CHAIN_ID \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast ae "constructor(string,address,address,address)()" $SELF_TRANSFER_HOOK_NAME $SELF_TRANSFER_HOOK_VOTER $SELF_TRANSFER_HOOK_REWARDS_AUTHORIZED $SELF_PASSPORT_SBT) \
    --compiler-version "v0.8.27" \
    --verifier etherscan \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}


# AutoUnwrapHook
forge verify-contract \
    $AUTO_UNWRAP_HOOK \
    src/hooks/extensions/AutoUnwrapHook.sol:AutoUnwrapHook \
    --chain-id $CHAIN_ID \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast ae "constructor(string,address,address,address[],address[])()" $AUTO_UNWRAP_HOOK_NAME $SELF_TRANSFER_HOOK_VOTER $SELF_TRANSFER_HOOK_REWARDS_AUTHORIZED "[$SELF_VERIFIED_ERC20]" "[$ERC20_LOCKBOX]") \
    --compiler-version "v0.8.27" \
    --verifier etherscan \
    --verifier-url $ETHERSCAN_VERIFIER_URL \
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}
