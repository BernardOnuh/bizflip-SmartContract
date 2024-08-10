// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title BizflipArtTradable
 * BizflipArtTradable - ERC1155 contract that whitelists an operator address, 
 * has mint functionality, and supports useful standards from OpenZeppelin,
 * like _exists(), name(), symbol(), and totalSupply()
 */
contract BizflipArtTradable is ERC1155, ERC1155Burnable, ERC1155Supply, ERC1155URIStorage, Ownable {
    uint256 private _currentTokenID = 0;

    mapping(uint256 => address) public creators;

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
        address _bundleMarketplace
    ) ERC1155("") Ownable(msg.sender) {
        name = _name;
        symbol = _symbol;
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;
        marketplace = _marketplace;
        bundleMarketplace = _bundleMarketplace;
    }

    function uri(uint256 _id) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        require(_exists(_id), "ERC1155: URI query for nonexistent token");
        return ERC1155URIStorage.uri(_id);
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
    ) external payable {
        require(msg.value >= platformFee, "Insufficient funds to mint.");

        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();

        creators[_id] = msg.sender;
        _setURI(_id, _uri);

        _mint(_to, _id, _supply, "");

        // Send native currency fee to fee recipient
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

    /**
     * @dev Override the `_update` function to resolve the conflict between ERC1155 and ERC1155Supply
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
