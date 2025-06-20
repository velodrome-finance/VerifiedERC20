// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../BaseSelfForkFixture.sol";

import {IReward} from "../../../src/interfaces/external/IReward.sol";
import {ILeafVoter} from "../../../src/interfaces/external/ILeafVoter.sol";
import {IPoolFactory} from "../../../src/interfaces/external/IPoolFactory.sol";
import {VelodromeTimeLibrary} from "../../../src/libraries/VelodromeTimeLibrary.sol";

contract IncentiveFlowTest is BaseSelfForkFixture {
    address leafHLMessageModule = 0x2BbA7515F7cF114B45186274981888D8C2fBA15E;
    address leafVoter = 0x97cDBCe21B6fd0585d29E539B1B99dAd328a1123;
    uint256 incentiveAmount = 1000 * TOKEN_1;
    uint256 aliceTokenId = 1;
    uint256 bobTokenId = 2;
    uint256 charlieTokenId = 3;

    function setUp() public override {
        super.setUp();

        address poolFactory = 0x31832f2a97Fd20664D76Cc421207669b55CE4BC0;
        address votingRewardsFactory = 0x7dc9fd82f91B36F416A89f5478375e4a79f4Fb2F;
        address gaugeFactory = 0x42e403b73898320f23109708b0ba1Ae85838C445;

        // create pool and gauge to WL verifiedERC20
        address pool = IPoolFactory(poolFactory).createPool({tokenA: CELO, tokenB: address(verifiedERC20), fee: 0});

        vm.prank(leafHLMessageModule);
        ILeafVoter(leafVoter).createGauge({
            _poolFactory: poolFactory,
            _pool: pool,
            _votingRewardsFactory: votingRewardsFactory,
            _gaugeFactory: gaugeFactory
        });

        // mint celo to alice to deposit incentive
        deal({token: CELO, to: users.alice, give: incentiveAmount});
        vm.startPrank(users.alice);
        IERC20(CELO).approve({spender: address(lockbox), value: incentiveAmount});
        lockbox.deposit({_amount: incentiveAmount});
        vm.stopPrank();

        // mock alice and bob verification
        selfPassportSBT.mint({to: users.alice, tokenId: aliceTokenId});
        selfPassportSBT.mint({to: users.bob, tokenId: bobTokenId});

        // alice and bob need to approve auto unwrap hook beforehand
        vm.prank(users.alice);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: type(uint256).max});
        vm.prank(users.bob);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: type(uint256).max});
        vm.prank(users.charlie);
        verifiedERC20.approve({spender: address(autoUnwrapHook), value: type(uint256).max});
    }

    function test_IncentiveFlow() public {
        // USDT/WETH pool on Celo
        address pool = 0xA6A14E6767C07Ffba3786Ac0054A8647Cfdca58D;
        address gauge = ILeafVoter(leafVoter).gauges(pool);

        address ivr = ILeafVoter(leafVoter).gaugeToIncentive({_gauge: gauge});

        skipToNextEpoch(1);

        //DEPOSIT INCENTIVE
        vm.startPrank(users.alice);
        verifiedERC20.approve({spender: ivr, value: incentiveAmount});
        IReward(ivr).notifyRewardAmount({token: address(verifiedERC20), amount: incentiveAmount});
        vm.stopPrank();

        // ALICE, BOB AND CHARLIE VOTE FOR GAUGE
        uint256 aliceVotingPower = 1000 * TOKEN_1;
        uint256 bobVotingPower = 2000 * TOKEN_1;
        uint256 charlieVotingPower = 1000 * TOKEN_1;

        vm.startPrank(leafHLMessageModule);
        IReward(ivr)._deposit({amount: aliceVotingPower, tokenId: aliceTokenId, timestamp: block.timestamp});
        IReward(ivr)._deposit({amount: bobVotingPower, tokenId: bobTokenId, timestamp: block.timestamp});
        IReward(ivr)._deposit({amount: charlieVotingPower, tokenId: charlieTokenId, timestamp: block.timestamp});
        vm.stopPrank();

        // ALICE, BOB AND CHARLIE CLAIM INCENTIVE
        skipToNextEpoch(3 hours);

        address[] memory tokens = new address[](1);
        tokens[0] = address(verifiedERC20);

        assertEq(IERC20(CELO).balanceOf(users.alice), 0);
        assertEq(IERC20(CELO).balanceOf(users.bob), 0);
        assertEq(IERC20(CELO).balanceOf(users.charlie), 0);
        assertEq(IERC20(CELO).balanceOf(address(lockbox)), incentiveAmount);
        assertEq(verifiedERC20.balanceOf(users.alice), 0);
        assertEq(verifiedERC20.balanceOf(users.bob), 0);
        assertEq(verifiedERC20.balanceOf(users.charlie), 0);
        assertEq(verifiedERC20.balanceOf(address(ivr)), incentiveAmount);

        uint256 aliceReward = 1112944070707655659;
        uint256 bobReward = 2225888141415311318;
        uint256 charlieReward = 1112944070707655659;

        vm.expectEmit(address(lockbox));
        emit IERC20Lockbox.Withdraw({_sender: address(autoUnwrapHook), _receiver: users.alice, _amount: aliceReward});
        vm.prank(leafHLMessageModule);
        IReward(ivr).getReward({_recipient: users.alice, _tokenId: aliceTokenId, _tokens: tokens});

        assertEq(IERC20(CELO).balanceOf(users.alice), aliceReward);
        assertEq(IERC20(CELO).balanceOf(users.bob), 0);
        assertEq(IERC20(CELO).balanceOf(users.charlie), 0);
        assertEq(IERC20(CELO).balanceOf(address(lockbox)), incentiveAmount - aliceReward);
        assertEq(verifiedERC20.balanceOf(users.alice), 0);
        assertEq(verifiedERC20.balanceOf(users.bob), 0);
        assertEq(verifiedERC20.balanceOf(users.charlie), 0);
        assertEq(verifiedERC20.balanceOf(address(ivr)), incentiveAmount - aliceReward);

        vm.expectEmit(address(lockbox));
        emit IERC20Lockbox.Withdraw({_sender: address(autoUnwrapHook), _receiver: users.bob, _amount: bobReward});
        vm.prank(leafHLMessageModule);
        IReward(ivr).getReward({_recipient: users.bob, _tokenId: bobTokenId, _tokens: tokens});

        assertEq(IERC20(CELO).balanceOf(users.alice), aliceReward);
        assertEq(IERC20(CELO).balanceOf(users.bob), bobReward);
        assertEq(IERC20(CELO).balanceOf(users.charlie), 0);
        assertEq(IERC20(CELO).balanceOf(address(lockbox)), incentiveAmount - aliceReward - bobReward);
        assertEq(verifiedERC20.balanceOf(users.alice), 0);
        assertEq(verifiedERC20.balanceOf(users.bob), 0);
        assertEq(verifiedERC20.balanceOf(users.charlie), 0);
        assertEq(verifiedERC20.balanceOf(address(ivr)), incentiveAmount - aliceReward - bobReward);

        // Charlie is not verified. Get reward will revert
        vm.expectRevert(
            abi.encodeWithSelector(
                IVerifiedERC20.VerifiedERC20_HookRevert.selector,
                abi.encode(
                    bytes32(
                        abi.encodeWithSelector(
                            IHook.Hook_Revert.selector, abi.encode(address(this), users.charlie, charlieReward)
                        )
                    )
                )
            )
        );
        vm.prank(leafHLMessageModule);
        IReward(ivr).getReward({_recipient: users.charlie, _tokenId: charlieTokenId, _tokens: tokens});

        // Charlie verifies to be able to claim rewards
        selfPassportSBT.mint({to: users.charlie, tokenId: charlieTokenId});

        vm.expectEmit(address(lockbox));
        emit IERC20Lockbox.Withdraw({_sender: address(autoUnwrapHook), _receiver: users.charlie, _amount: charlieReward});
        vm.prank(leafHLMessageModule);
        IReward(ivr).getReward({_recipient: users.charlie, _tokenId: charlieTokenId, _tokens: tokens});

        assertEq(IERC20(CELO).balanceOf(users.alice), aliceReward);
        assertEq(IERC20(CELO).balanceOf(users.bob), bobReward);
        assertEq(IERC20(CELO).balanceOf(users.charlie), charlieReward);
        assertEq(IERC20(CELO).balanceOf(address(lockbox)), incentiveAmount - aliceReward - bobReward - charlieReward);
        assertEq(verifiedERC20.balanceOf(users.alice), 0);
        assertEq(verifiedERC20.balanceOf(users.bob), 0);
        assertEq(verifiedERC20.balanceOf(users.charlie), 0);
        assertEq(verifiedERC20.balanceOf(address(ivr)), incentiveAmount - aliceReward - bobReward - charlieReward);
    }

    function skipToNextEpoch(uint256 offset) internal {
        uint256 nextEpoch = VelodromeTimeLibrary.epochNext(block.timestamp);
        uint256 newTimestamp = nextEpoch + offset;
        uint256 diff = newTimestamp - block.timestamp;
        vm.warp(newTimestamp);
        vm.roll(block.number + diff / 2);
    }
}
