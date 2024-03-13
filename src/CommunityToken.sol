// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CommunityToken is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    error OnlyTokenOwner(address owner, address sender, uint256 tokenId);

    // CommunityRegistry deploys this contract and is the owner
    constructor(string memory name, string memory symbol, address initialOwner)
        ERC721(name, symbol)
        Ownable(initialOwner)
    {}

    //////////////////////////////////////
    // Overrides required by Solidity   //
    //////////////////////////////////////

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //////////////////////////////////////
    // Public Functions                 //
    //////////////////////////////////////

    /**
     * Enforce token transfers through the CommunityRegistry contract
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyOwner {
        super.transferFrom(from, to, tokenId);
    }

    /**
     * Mint a new token and assign it to the given address.
     * Only the registry contract is allowed to mint tokens.
     */
    function safeMint(address to, string memory uri) public onlyOwner returns(uint256) {
        uint256 tokenId = ++_nextTokenId;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    /**
     * Only CommunityRegistry is allowed to call this function.
     * @return The new owner of the token and the token id.
     */
    fallback(bytes calldata args) external onlyOwner returns (bytes memory) {
        (address from, address to, uint256 tokenId) = abi.decode(args, (address, address, uint256));
        if (ownerOf(tokenId) != from) revert OnlyTokenOwner(ownerOf(tokenId), from, tokenId);
        _safeTransfer(from, to, tokenId);
        return abi.encode(to, tokenId);
    }
}
