// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../../../BaseSelfForkFixture.sol";

contract VerifiedERC20Test is BaseSelfForkFixture {
    function test_InitialState() public view {
        assertEq(verifiedERC20.name(), _selfParams.verifiedERC20Name);
        assertEq(verifiedERC20.symbol(), _selfParams.verifiedERC20Symbol);
        assertEq(Ownable(verifiedERC20).owner(), _selfParams.verifiedERC20Owner);
        assertEq(verifiedERC20.hookRegistry(), address(hookRegistry));

        // mapping(address _hook => uint256) public hookToIndex;
        assertEq(verifiedERC20.hookToIndex(address(singlePermissionMintHook)), 0);
        assertEq(verifiedERC20.hookToIndex(address(singlePermissionBurnHook)), 0);
        assertEq(verifiedERC20.hookToIndex(address(selfTransferHook)), 0);

        // mapping(address _hook => IHookRegistry.Entrypoint) public hookToEntrypoint;
        assertEq(
            uint8(verifiedERC20.hookToEntrypoint(address(singlePermissionMintHook))),
            uint8(IHookRegistry.Entrypoint.BEFORE_MINT)
        );
        assertEq(
            uint8(verifiedERC20.hookToEntrypoint(address(singlePermissionBurnHook))),
            uint8(IHookRegistry.Entrypoint.BEFORE_BURN)
        );
        assertEq(
            uint8(verifiedERC20.hookToEntrypoint(address(selfTransferHook))),
            uint8(IHookRegistry.Entrypoint.BEFORE_TRANSFER)
        );

        // mapping(address _hook => bool) public isHookActivated;
        assertTrue(verifiedERC20.isHookActivated(address(singlePermissionMintHook)));
        assertTrue(verifiedERC20.isHookActivated(address(singlePermissionBurnHook)));
        assertTrue(verifiedERC20.isHookActivated(address(selfTransferHook)));

        // getHooksForEntrypoint(IHookRegistry.Entrypoint _entrypoint)
        address[] memory mintHooks = verifiedERC20.getHooksForEntrypoint(IHookRegistry.Entrypoint.BEFORE_MINT);
        assertEq(mintHooks.length, 1);
        assertEq(mintHooks[0], address(singlePermissionMintHook));
        address[] memory burnHooks = verifiedERC20.getHooksForEntrypoint(IHookRegistry.Entrypoint.BEFORE_BURN);
        assertEq(burnHooks.length, 1);
        assertEq(burnHooks[0], address(singlePermissionBurnHook));
        address[] memory transferHooks = verifiedERC20.getHooksForEntrypoint(IHookRegistry.Entrypoint.BEFORE_TRANSFER);
        assertEq(transferHooks.length, 1);
        assertEq(transferHooks[0], address(selfTransferHook));

        // getHookAtIndex(IHookRegistry.Entrypoint _entrypoint, uint256 _index)
        assertEq(
            verifiedERC20.getHookAtIndex(IHookRegistry.Entrypoint.BEFORE_MINT, 0), address(singlePermissionMintHook)
        );
        assertEq(
            verifiedERC20.getHookAtIndex(IHookRegistry.Entrypoint.BEFORE_BURN, 0), address(singlePermissionBurnHook)
        );
        assertEq(verifiedERC20.getHookAtIndex(IHookRegistry.Entrypoint.BEFORE_TRANSFER, 0), address(selfTransferHook));

        // getHooksCountForEntrypoint(IHookRegistry.Entrypoint _entrypoint)
        assertEq(verifiedERC20.getHooksCountForEntrypoint(IHookRegistry.Entrypoint.BEFORE_MINT), 1);
        assertEq(verifiedERC20.getHooksCountForEntrypoint(IHookRegistry.Entrypoint.BEFORE_BURN), 1);
        assertEq(verifiedERC20.getHooksCountForEntrypoint(IHookRegistry.Entrypoint.BEFORE_TRANSFER), 1);
    }
}
