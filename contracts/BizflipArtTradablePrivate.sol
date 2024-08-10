// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

/**
 * @title BizflipArtTradablePrivate
 * BizflipArtTradablePrivate - ERC1155 contract that whitelists an operator address, 
 * has mint functionality, and supports useful standards from OpenZeppelin,
 * like _exists(), name(), symbol(), and totalSupply()
 */
contract BizflipArtTradablePrivate is ERC1155Burnable, ERC1155URIStorage, Ownable {
    event UpdatePlatformFee(uint256 platformFee);

    uint256 private _currentTokenID = 0;

    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenSupply;

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;
    // Platform fee
    uint256 public platformFee;
    // Platform fee recipient
    address payable public feeRecipient;
    // Bizflip Marketplace contract
    address marketplace;
    // Bizflip Bundle Marketplace contract
    address bundleMarketplace;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _platformFee,
        address payable _feeRecipient,
        address _marketplace,
        address _bundleMarketplace,
        address initialOwner // Add this parameter
    ) ERC1155("") Ownable(initialOwner) {
        name = _name;
        symbol = _symbol;
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;
        marketplace = _marketplace;
        bundleMarketplace = _bundleMarketplace;
    }

    function uri(uint256 _id) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        require(_exists(_id), "ERC1155: NONEXISTENT_TOKEN");
        return super.uri(_id);
    }

    /**
     * @dev Returns the total quantity for a token ID
     * @param _id uint256 ID of the token to query
     * @return amount of token in existence
     */
    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    /**
     * @dev Creates a new token type and assigns _supply to an address
     * @param _to owner address of the new token
     * @param _supply Optional amount to supply the first owner
     * @param _uri Optional URI for this token type
     */
    function mint(
        address _to,
        uint256 _supply,
        string calldata _uri
    ) external payable onlyOwner {
        require(msg.value >= platformFee, "Insufficient funds to mint.");

        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();

        creators[_id] = msg.sender;
        _setURI(_id, _uri);

        if (bytes(_uri).length > 0) {
            emit URI(_uri, _id);
        }

        _mint(_to, _id, _supply, bytes(""));
        tokenSupply[_id] = _supply;

        // Send FTM fee to fee recipient
        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Transfer failed");
    }

    function getCurrentTokenID() public view returns (uint256) {
        return _currentTokenID;
    }

    /**
     * Override isApprovedForAll to whitelist Bizflip contracts to enable gas-less listings.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        // Whitelist Bizflip marketplace, bundle marketplace contracts for easy trading.
        if (marketplace == _operator || bundleMarketplace == _operator) {
            return true;
        }

        return super.isApprovedForAll(_owner, _operator);
    }

    /**
     * @dev Returns whether the specified token exists by checking to see if it has a creator
     * @param _id uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    /**
     @notice Method for updating platform fee
     @dev Only admin
     @param _platformFee uint256 the platform fee to set
     */
    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
        emit UpdatePlatformFee(_platformFee);
    }
    
    /**
     * @dev calculates the next token ID based on value of _currentTokenID
     * @return uint256 for the next token ID
     */
    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID + 1;
    }

    /**
     * @dev increments the value of _currentTokenID
     */
    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param _id uint256 ID of the token to set its URI
     * @param _uri string URI to assign
     */
    function _setURI(uint256 _id, string memory _uri) internal override {
        require(_exists(_id), "_setURI: Token should exist");
        super._setURI(_id, _uri);
    }
}
