#!/bin/bash

# SelfVerifiedERC20 Contract Addresses
ERC20_LOCKBOX="0x2a8e69bCb395752DbFb45Bd0440cc43479B19bD5"
SINGLE_PERMISSION_MINT_HOOK="0xB082e39D302968C1C19F9b44648e49f86aDF88c8"
SINGLE_PERMISSION_BURN_HOOK="0x6401DC78AD9eef87F2Bd3FB94f87C3147E349d61"
SELF_TRANSFER_HOOK="0x81Cf20B5926d9F1db87A48Eb461a7f87Dcf1ae65"
AUTO_UNWRAP_HOOK="0xf9D085cB03350eC8866852a0139e40ea54f191bd"
SELF_VERIFIED_ERC20="0x286C3f508Df957889111571ddbD572b31AdE44b0"
#TODO: remove after verifying
MOCK_INCENTIVE="0xF76DAfd32c8f862767b21a6D5C76a6bB7B3C0411"

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

# HOOK_REGISTRY_OWNER=$(cast call $HOOK_REGISTRY --rpc-url $RPC_URL "owner()(address)")
# VERIFIED_ERC20="0xFf070228fE09569ee34874eb6a086CbBA065aaF0"
# HOOK_REGISTRY="0x5657a494a9Af4065431498bBC5F8c7D53148988D"
# VERIFIED_ERC20_FACTORY="0x609B89df1E42108eC4Bd17C2FF2487C9A031B0e0"

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
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY} \
    --delay 10

sleep 5

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
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY} \
    --delay 10

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
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY} \
    --delay 10

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
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY} \
    --delay 10


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
    ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY} \
    --delay 10
#
# #TODO: remove after verifying
# # MockSelfPassportSBT 
# forge verify-contract \
#     $SELF_PASSPORT_SBT \
#     test/mocks/MockSelfPassportSBT.sol:MockSelfPassportSBT \
#     --chain-id $CHAIN_ID \
#     --num-of-optimizations 200 \
#     --watch \
#     --constructor-args $(cast ae "constructor()()") \
#     --compiler-version "v0.8.27" \
#     --verifier etherscan \
#     --verifier-url $ETHERSCAN_VERIFIER_URL \
#     ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}
#
# # MockIncentive
# forge verify-contract \
#     $MOCK_INCENTIVE \
#     test/mocks/MockIncentiveReward.sol:MockIncentiveReward \
#     --chain-id $CHAIN_ID \
#     --num-of-optimizations 200 \
#     --watch \
#     --constructor-args $(cast ae "constructor()()") \
#     --compiler-version "v0.8.27" \
#     --verifier etherscan \
#     --verifier-url $ETHERSCAN_VERIFIER_URL \
#     ${ETHERSCAN_API_KEY:+--etherscan-api-key $ETHERSCAN_API_KEY}
