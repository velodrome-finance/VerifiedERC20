# Permissioned ERC20 Specification

This document outlines the specification for `PermissionedERC20`, which extends ERC20 functionality with a flexible hook system for permission management.

## System Overview

The `PermissionedERC20` system consists of three main components:
1. `PermissionedERC20Factory` - Factory contract for deploying new `PermissionedERC20` instances
2. `PermissionedERC20` - The main token contract that extends `ERC20` with hook functionality
3. `HookRegistry` - Registry contract that manages hooks for a `PermissionedERC20` instance

## Contracts

### `PermissionedERC20Factory`

The factory contract is responsible for deploying new `PermissionedERC20` instances with their associated `HookRegistry`.

### `HookRegistry`

The registry contract manages hooks for a `PermissionedERC20` instance. Each hook can be associated with specific entrypoints and can be activated/deactivated.

### `PermissionedERC20`

The main contract that extends OpenZeppelin's `ERC20` implementation with hook functionality.

## Hook Integration

Hooks must implement the `IHook` interface and are added to the `PermissionedERC20` by the `PermissionedERC20.owner()`. It needs to call `addHook` along with the entrypoint for the hook.
