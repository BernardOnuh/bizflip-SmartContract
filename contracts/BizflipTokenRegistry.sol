// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BizflipTokenRegistry is Ownable {
    /// @dev Events of the contract
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);

    /// @notice ERC20 Address -> Bool
    mapping(address => bool) public enabled;

    /**
     @notice Constructor that sets the initial owner of the contract
     @param initialOwner The address of the initial owner
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     @notice Method for adding payment token
     @dev Only admin
     @param token ERC20 token address
     */
    function add(address token) external onlyOwner {
        require(!enabled[token], "Token already added");
        enabled[token] = true;
        emit TokenAdded(token);
    }

    /**
     @notice Method for removing payment token
     @dev Only admin
     @param token ERC20 token address
     */
    function remove(address token) external onlyOwner {
        require(enabled[token], "Token does not exist");
        enabled[token] = false;
        emit TokenRemoved(token);
    }
}
