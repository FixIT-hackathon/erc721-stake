pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract TestERC721 is ERC721Enumerable  {
    mapping(uint256 => string) _tokenURIs;

    constructor(address[] memory receivers, string[] memory uris) ERC721("Test", "TT") {
        for (uint i = 0; i < receivers.length; i++) {
            _mint(receivers[i], i);
            _tokenURIs[i] = uris[i];
        }
    }

    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal virtual
    {
        require(_exists(tokenId),"ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = tokenURI;
    }

    function tokenURI(uint256 tokenId ) public view override returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
}
