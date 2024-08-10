// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BizflipNFTTradablePrivate
 * BizflipNFTTradablePrivate - ERC721 contract that whitelists a trading address and has minting functionality.
 */
contract BizflipNFTTradablePrivate is ERC721URIStorage, Ownable {
    /// @dev Events of the contract
    event Minted(
        uint256 tokenId,
        address beneficiary,
        string tokenUri,
        address minter
    );
    event UpdatePlatformFee(uint256 platformFee);
    event UpdateFeeRecipient(address payable feeRecipient);

    address public auction;
    address public marketplace;
    address public bundleMarketplace;
    uint256 private _currentTokenId = 0;

    /// @notice Platform fee
    uint256 public platformFee;

    /// @notice Platform fee recipient
    address payable public feeRecipient;

    /// @dev Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    /// @notice Contract constructor
    constructor(
        string memory _name,
        string memory _symbol,
        address _auction,
        address _marketplace,
        address _bundleMarketplace,
        uint256 _platformFee,
        address payable _feeRecipient,
        address initialOwner
    ) ERC721(_name, _symbol) Ownable(initialOwner) {
        auction = _auction;
        marketplace = _marketplace;
        bundleMarketplace = _bundleMarketplace;
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;
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
     @notice Method for updating platform fee address
     @dev Only admin
     @param _feeRecipient payable address the address to send the funds to
     */
    function updateFeeRecipient(address payable _feeRecipient)
        external
        onlyOwner
    {
        feeRecipient = _feeRecipient;
        emit UpdateFeeRecipient(_feeRecipient);
    }

    /**
     * @dev Mints a token to an address with a tokenURI.
     * @param _to address of the future owner of the token
     */
    function mint(address _to, string calldata _tokenUri)
        external
        payable
        onlyOwner
    {
        require(msg.value >= platformFee, "Insufficient funds to mint.");

        uint256 newTokenId = _getNextTokenId();
        _safeMint(_to, newTokenId);
        _owners[newTokenId] = _to;
        _setTokenURI(newTokenId, _tokenUri);
        _incrementTokenId();

        // Send FTM fee to fee recipient
        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Transfer failed");

        emit Minted(newTokenId, _to, _tokenUri, _msgSender());
    }

    /**
    @notice Burns a BizflipNFT, releasing any composed 1155 tokens held by the token itself
    @dev Only the owner or an approved sender can call this method
    @param _tokenId the token ID to burn
    */
    function burn(uint256 _tokenId) external {
        address operator = _msgSender();
        require(
            ownerOf(_tokenId) == operator || isApproved(_tokenId, operator),
            "Only NFT owner or approved"
        );

        // Destroy token mappings
        _burn(_tokenId);
        delete _owners[_tokenId];
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenId
     * @return uint256 for the next token ID
     */
    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId + 1;
    }

    /**
     * @dev increments the value of _currentTokenId
     */
    function _incrementTokenId() private {
        _currentTokenId++;
    }

    /**
     * @dev checks if the given token ID is approved either for all or the single token ID
     */
    function isApproved(uint256 _tokenId, address _operator)
        public
        view
        returns (bool)
    {
        return
            isApprovedForAll(ownerOf(_tokenId), _operator) ||
            getApproved(_tokenId) == _operator;
    }

   /**
    * Override isApprovedForAll to whitelist Bizflip contracts to enable gas-less listings.
    */
    function isApprovedForAll(address owner, address operator)
        public
        view
        override(ERC721, IERC721)
        returns (bool)
    {
        // Whitelist Bizflip auction, marketplace, bundle marketplace contracts for easy trading.
        if (
            auction == operator ||
            marketplace == operator ||
            bundleMarketplace == operator
        ) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}
