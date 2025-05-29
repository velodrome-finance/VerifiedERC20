// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20Factory.t.sol";

contract DeployVerifiedERC20UnitConcreteTest is VerifiedERC20FactoryTest {
    function test_WhenOwnerIsZeroAddress(string memory _name, string memory _symbol) external {
        // It should revert with {OwnableInvalidOwner}
        address _owner = address(0);
        address[] memory _hooks = new address[](0);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        verifiedERC20Factory.deployVerifiedERC20({_name: _name, _symbol: _symbol, _owner: _owner, _hooks: _hooks});
    }

    function test_WhenOwnerIsNotZeroAddress(string memory _name, string memory _symbol, address _owner) external {
        // It should deploy a new VerifiedERC20
        // It should increase the new VerifiedERC20 count
        // It should add the new VerifiedERC20 at the last index
        // It should return true on isVerfiedERC20
        // It should add the new VerifiedERC20 to the verifiedERC20s
        // It should emit a {VerifiedERC20Created} event
        vm.assume(_owner != address(0));
        address[] memory _hooks = new address[](0);
        vm.expectEmit(false, false, false, false, address(verifiedERC20Factory));
        emit IVerifiedERC20Factory.VerifiedERC20Created({verifiedERC20: address(0)});
        address newVerifiedER20 =
            verifiedERC20Factory.deployVerifiedERC20({_name: _name, _symbol: _symbol, _owner: _owner, _hooks: _hooks});

        assertEq(verifiedERC20Factory.getVerifiedERC20Count(), 2);
        assertEq(verifiedERC20Factory.getVerifiedERC20At(1), newVerifiedER20);
        assertTrue(verifiedERC20Factory.isVerifiedERC20(newVerifiedER20));
        address[] memory allVerifiedERC20s = verifiedERC20Factory.getAllVerifiedERC20s();
        assertEq(allVerifiedERC20s.length, 2);
        assertEq(allVerifiedERC20s[1], newVerifiedER20);
    }
}
