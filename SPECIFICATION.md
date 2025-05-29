# Verified ERC20 Specification

This document outlines the specification for `VerifiedERC20`, which extends ERC20 functionality with a flexible hook registry. The hooks provide integrations with onchain verification providers and operate as layers of permissions.

## System Overview

The `VerifiedERC20` system consists of three main components:
1. `VerifiedERC20Factory` - Factory contract for deploying new `VerifiedERC20` instances
2. `VerifiedERC20` - The main token contract that extends `ERC20` with hook functionality
3. `HookRegistry` - Registry contract that manages hooks for a `VerifiedERC20` instance

## Contracts

### `VerifiedERC20Factory`

The factory contract is responsible for deploying new `VerifiedERC20` instances.

### `HookRegistry`

The registry contract manages hooks for `VerifiedERC20` deployments. Each hook can be associated with specific `VerifiedERC20` entrypoints and can be activated/deactivated.

### `VerifiedERC20`

The main contract that extends OpenZeppelin's `ERC20` implementation with hook functionality.

## Hook Integration

Hooks must implement the `IHook` interface and need to be added first to the registry before these can be enabled for a `VerifiedERC20` by its `VerifiedERC20.owner()`. 
