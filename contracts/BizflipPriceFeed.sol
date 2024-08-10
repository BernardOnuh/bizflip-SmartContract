// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IBizflipAddressRegistry {
    function tokenRegistry() external view returns (address);
}

interface IBizflipTokenRegistry {
    function enabled(address) external view returns (bool);
}

interface IOracle {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256);
}

contract BizflipPriceFeed is Ownable {
    /// @notice keeps track of oracles for each token
    mapping(address => address) public oracles;

    /// @notice Bizflip address registry contract
    address public addressRegistry;

    /// @notice wrapped FTM contract
    address public wETH;

    /**
     * @notice Initialize the contract with the address registry and wETH addresses
     * @param _addressRegistry Address of the address registry contract
     * @param _wETH Address of the wrapped FTM contract
     * @param _initialOwner Address of the initial owner
     */
    constructor(address _addressRegistry, address _wETH, address _initialOwner)
        Ownable(msg.sender) 
    {
        transferOwnership(_initialOwner); 
        addressRegistry = _addressRegistry;
        wETH = _wETH;
    }

    /**
     * @notice Register oracle contract to token
     * @dev Only owner can register oracle
     * @param _token ERC20 token address
     * @param _oracle Oracle address
     */
    function registerOracle(address _token, address _oracle)
        external
        onlyOwner
    {
        IBizflipTokenRegistry tokenRegistry = IBizflipTokenRegistry(
            IBizflipAddressRegistry(addressRegistry).tokenRegistry()
        );
        require(tokenRegistry.enabled(_token), "invalid token");
        require(oracles[_token] == address(0), "oracle already set");

        oracles[_token] = _oracle;
    }

    /**
     * @notice Update oracle address for token
     * @dev Only owner can update oracle
     * @param _token ERC20 token address
     * @param _oracle Oracle address
     */
    function updateOracle(address _token, address _oracle) external onlyOwner {
        require(oracles[_token] != address(0), "oracle not set");

        oracles[_token] = _oracle;
    }

    /**
     * @notice Get current price for token
     * @dev Return current price or if oracle is not registered returns 0
     * @param _token ERC20 token address
     */
    function getPrice(address _token) external view returns (int256, uint8) {
        if (oracles[_token] == address(0)) {
            return (0, 0);
        }

        IOracle oracle = IOracle(oracles[_token]);
        return (oracle.latestAnswer(), oracle.decimals());
    }

    /**
     * @notice Update address registry contract
     * @dev Only owner
     * @param _addressRegistry New address registry contract address
     */
    function updateAddressRegistry(address _addressRegistry) external onlyOwner {
        addressRegistry = _addressRegistry;
    }
}
