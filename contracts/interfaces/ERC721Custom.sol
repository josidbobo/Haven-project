//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract ERC721Custom is ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    mapping (uint256 => string) private _tokenURIs;
    string private baseURI;

    constructor(string memory name, string memory symbol, string memory baseTokenURI) ERC721(name, symbol) {
        baseURI = baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if(bytes(base).length > 0){
            return string(abi.encodePacked(base, _tokenURI));
        }
        return _tokenURI;
    }


    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function safeMint(address to, string memory metadataURI) external onlyOwner {
        _safeMint(to, _tokenIds.current());
        _setTokenURI(_tokenIds.current(), metadataURI);
        _tokenIds.increment();
    }

    function burn(uint256 tokenId) external {
        require(msg.sender == ownerOf(tokenId), "ERC721: Not the owner of the token");
        _burn(tokenId);
    }


    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

}
