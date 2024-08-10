// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BizflipAddressRegistry is Ownable {
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    /// @notice Artion contract
    address public artion;

    /// @notice BizflipAuction contract
    address public auction;

    /// @notice BizflipMarketplace contract
    address public marketplace;

    /// @notice BizflipBundleMarketplace contract
    address public bundleMarketplace;

    /// @notice BizflipNFTFactory contract
    address public factory;

    /// @notice BizflipNFTFactoryPrivate contract
    address public privateFactory;

    /// @notice BizflipArtFactory contract
    address public artFactory;

    /// @notice BizflipArtFactoryPrivate contract
    address public privateArtFactory;

    /// @notice BizflipTokenRegistry contract
    address public tokenRegistry;

    /// @notice BizflipPriceFeed contract
    address public priceFeed;

    /**
     * @notice Constructor that sets the initial owner
     * @param initialOwner The address of the initial owner
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Update artion contract
     * @dev Only admin
     * @param _artion The new address for the Artion contract
     */
    function updateArtion(address _artion) external onlyOwner {
        require(
            IERC165(_artion).supportsInterface(INTERFACE_ID_ERC721),
            "Not ERC721"
        );
        artion = _artion;
    }

    /**
     * @notice Update BizflipAuction contract
     * @dev Only admin
     * @param _auction The new address for the BizflipAuction contract
     */
    function updateAuction(address _auction) external onlyOwner {
        auction = _auction;
    }

    /**
     * @notice Update BizflipMarketplace contract
     * @dev Only admin
     * @param _marketplace The new address for the BizflipMarketplace contract
     */
    function updateMarketplace(address _marketplace) external onlyOwner {
        marketplace = _marketplace;
    }

    /**
     * @notice Update BizflipBundleMarketplace contract
     * @dev Only admin
     * @param _bundleMarketplace The new address for the BizflipBundleMarketplace contract
     */
    function updateBundleMarketplace(address _bundleMarketplace)
        external
        onlyOwner
    {
        bundleMarketplace = _bundleMarketplace;
    }

    /**
     * @notice Update BizflipNFTFactory contract
     * @dev Only admin
     * @param _factory The new address for the BizflipNFTFactory contract
     */
    function updateNFTFactory(address _factory) external onlyOwner {
        factory = _factory;
    }

    /**
     * @notice Update BizflipNFTFactoryPrivate contract
     * @dev Only admin
     * @param _privateFactory The new address for the BizflipNFTFactoryPrivate contract
     */
    function updateNFTFactoryPrivate(address _privateFactory)
        external
        onlyOwner
    {
        privateFactory = _privateFactory;
    }

    /**
     * @notice Update BizflipArtFactory contract
     * @dev Only admin
     * @param _artFactory The new address for the BizflipArtFactory contract
     */
    function updateArtFactory(address _artFactory) external onlyOwner {
        artFactory = _artFactory;
    }

    /**
     * @notice Update BizflipArtFactoryPrivate contract
     * @dev Only admin
     * @param _privateArtFactory The new address for the BizflipArtFactoryPrivate contract
     */
    function updateArtFactoryPrivate(address _privateArtFactory)
        external
        onlyOwner
    {
        privateArtFactory = _privateArtFactory;
    }

    /**
     * @notice Update token registry contract
     * @dev Only admin
     * @param _tokenRegistry The new address for the BizflipTokenRegistry contract
     */
    function updateTokenRegistry(address _tokenRegistry) external onlyOwner {
        tokenRegistry = _tokenRegistry;
    }

    /**
     * @notice Update price feed contract
     * @dev Only admin
     * @param _priceFeed The new address for the BizflipPriceFeed contract
     */
    function updatePriceFeed(address _priceFeed) external onlyOwner {
        priceFeed = _priceFeed;
    }
}
