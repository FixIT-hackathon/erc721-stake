pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract TestERC721 is ERC721Enumerable  {
    mapping(uint256 => string) _tokenURIs;

    constructor() ERC721("Test", "TT") {
        _mint(0x57f9A3a483d7D14c755175153b195Aa1e68Fd928, 0);
        _mint(0x57f9A3a483d7D14c755175153b195Aa1e68Fd928, 1);
        _tokenURIs[0] = "https://gateway.ipfs.io/ipfs/QmTkfdr1oF5a8FPWtsFm8PqtMz1n72uHMwm6WR9HroaeT1";
        _tokenURIs[1] = "https://gateway.ipfs.io/ipfs/Qmf8o25WPGyLDaroTpJaXF9fErKxgSNtjaSuTEGUMJUfcX";
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
