// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title BizflipNFTTradable
 * @notice ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract BizflipNFTTradable is ERC721, Ownable {
    using Address for address payable;
    using Strings for uint256;

    /// @dev Events of the contract
    event Minted(
        uint256 tokenId,
        address beneficiary,
        string tokenUri,
        address minter
    );
    event UpdatePlatformFee(
        uint256 platformFee
    );
    event UpdateFeeRecipient(
        address payable feeRecipient
    );

    address public auction;
    address public marketplace;
    address public bundleMarketplace;
    uint256 private _currentTokenId = 0;

    /// @notice Platform fee
    uint256 public platformFee;

    /// @notice Platform fee recipient
    address payable public feeRecipient;

    /// @notice Mapping from token ID to token URI
    mapping(uint256 => string) private _tokenURIs;

    /// @notice Contract constructor
    constructor(
        string memory _name,
        string memory _symbol,
        address _auction,
        address _marketplace,
        address _bundleMarketplace,
        uint256 _platformFee,
        address payable _feeRecipient,
        address initialOwner // Add this parameter
    ) ERC721(_name, _symbol) Ownable(initialOwner) { // Pass it to Ownable
        auction = _auction;
        marketplace = _marketplace;
        bundleMarketplace = _bundleMarketplace;
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;
    }

    /**
     * @notice Method for updating platform fee
     * @dev Only admin
     * @param _platformFee uint256 the platform fee to set
     */
    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
        emit UpdatePlatformFee(_platformFee);
    }

    /**
     * @notice Method for updating platform fee recipient
     * @dev Only admin
     * @param _feeRecipient address payable the address to send the funds to
     */
    function updateFeeRecipient(address payable _feeRecipient)
        external
        onlyOwner
    {
        feeRecipient = _feeRecipient;
        emit UpdateFeeRecipient(_feeRecipient);
    }

    function _setTokenURIInternal(uint256 tokenId, string memory uri) private {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    function mint(address _to, string calldata _tokenUri) external payable {
        require(msg.value >= platformFee, "Insufficient funds to mint.");

        uint256 newTokenId = _getNextTokenId();
        _safeMint(_to, newTokenId);
        _setTokenURIInternal(newTokenId, _tokenUri);
        _incrementTokenId();

        // Send fee to fee recipient
        feeRecipient.sendValue(msg.value);

        emit Minted(newTokenId, _to, _tokenUri, _msgSender());
    }

    /**
     * @notice Burns a token
     * @dev Only the owner or an approved sender can call this method
     * @param _tokenId the token ID to burn
     */
    function burn(uint256 _tokenId) external {
        address operator = _msgSender();
        require(
            ownerOf(_tokenId) == operator || getApproved(_tokenId) == operator || isApprovedForAll(ownerOf(_tokenId), operator),
            "Only token owner or approved operator"
        );

        _burn(_tokenId);
    }

    /**
     * @dev Calculates the next token ID based on the value of _currentTokenId
     * @return uint256 for the next token ID
     */
    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId + 1;
    }

    /**
     * @dev Increments the value of _currentTokenId
     */
    function _incrementTokenId() private {
        _currentTokenId++;
    }

    /**
     * @dev Checks if the given token ID is approved either for all or the single token ID
     * @param _tokenId uint256 ID of the token
     * @param _operator address of the operator
     * @return bool whether the operator is approved
     */
    function isApproved(uint256 _tokenId, address _operator) public view returns (bool) {
        return isApprovedForAll(ownerOf(_tokenId), _operator) || getApproved(_tokenId) == _operator;
    }

    /**
     * @dev Override isApprovedForAll to whitelist specific addresses for easy trading
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        if (
            auction == operator ||
            marketplace == operator ||
            bundleMarketplace == operator
        ) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId > 0 && tokenId <= _currentTokenId;
    }

    /**
     * @dev Returns the token URI for a given token ID
     * @param tokenId uint256 the token ID
     * @return string the token URI
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
}
