// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import "../VerifiedERC20Factory.t.sol";

contract DeployVerifiedERC20UnitFuzzTest is VerifiedERC20FactoryTest {
    using CreateXLibrary for bytes11;

    function test_GivenAnyParameter(address _owner) external {
        // It should deploy a new VerifiedERC20
        // It should increase the new VerifiedERC20 count
        // It should add the new VerifiedERC20 at the last index
        // It should return true on isVerifiedERC20
        // It should add the new VerifiedERC20 to the verifiedERC20s
        // It should emit a {VerifiedERC20Created} event
        string memory _name = "TestVerifiedERC20";
        string memory _symbol = "TVerifiedERC20";
        address[] memory _hooks = new address[](0);

        bytes32 salt = keccak256(
            abi.encodePacked(block.chainid, verifiedERC20Factory.getVerifiedERC20Count(), _name, _symbol, _owner)
        );
        bytes11 entropy = bytes11(salt);
        salt = entropy.calculateSalt({_deployer: address(verifiedERC20Factory)});
        bytes32 guardedSalt = keccak256(abi.encodePacked(uint256(uint160(address(verifiedERC20Factory))), salt));

        address expectedVerifiedERC20 = cx.computeCreate2Address({
            salt: guardedSalt,
            initCodeHash: keccak256(
                abi.encodePacked(
                    hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
                    bytes20(verifiedERC20Factory.implementation()),
                    hex"5af43d82803e903d91602b57fd5bf3"
                )
            ),
            deployer: address(cx)
        });

        vm.expectEmit(address(verifiedERC20Factory));
        emit IVerifiedERC20Factory.VerifiedERC20Created({verifiedERC20: expectedVerifiedERC20});
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
