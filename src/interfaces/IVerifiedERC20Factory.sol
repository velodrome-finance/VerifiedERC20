// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

interface IVerifiedERC20Factory {
    /**
     * @notice Event emitted when a new VerifiedERC20 is created
     * @param verifiedERC20 The address of the newly created verifiedERC20
     */
    event VerifiedERC20Created(address indexed verifiedERC20);

    /**
     * @dev Error thrown when the hook registry address provided to the factory is zero.
     */
    error VerifiedERC20Factory_HookRegistry_ZeroAddress();

    /**
     * @dev Error thrown when the implementation address provided to the factory is zero.
     */
    error VerifiedERC20Factory_Implementation_ZeroAddress();

    /**
     * @notice VerifiedERC20 implementation used by this factory
     * @return Address of the VerifiedERC20 implementation
     */
    function implementation() external view returns (address);
    /**
     * @notice The address of the hook registry contract
     * @return Address of the hook registry
     */
    function hookRegistry() external view returns (address);

    /**
     * @notice Deploys a new VerifiedERC20 contract
     * @param _name The name of the token
     * @param _symbol The symbol of the token
     * @param _owner The owner of the token
     * @param _hooks The hooks to be registered for the token
     * @return The address of the newly created VerifiedERC20 contract
     */
    function deployVerifiedERC20(string memory _name, string memory _symbol, address _owner, address[] memory _hooks)
        external
        returns (address);

    /**
     * @notice Get the total number of verifiedERC20s created by this factory
     * @return The number of verifiedERC20s
     */
    function getVerifiedERC20Count() external view returns (uint256);

    /**
     * @notice Get the verifiedERC20 at the specified index
     * @param _index The index of the verifiedERC20 to retrieve
     * @return The address of the verifiedERC20
     */
    function getVerifiedERC20At(uint256 _index) external view returns (address);

    /**
     * @notice Check if an address is a verifiedERC20 created by this factory
     * @param _verifiedERC20 The address to check
     * @return True if the address is a verifiedERC20, false otherwise
     */
    function isVerifiedERC20(address _verifiedERC20) external view returns (bool);

    /**
     * @notice Get all verifiedERC20s created by this factory
     * @return An array of all verifiedERC20 addresses
     */
    function getAllVerifiedERC20s() external view returns (address[] memory);
}
