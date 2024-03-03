// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {TokenTransferRequest} from "./TokenTransferRequest.sol";

contract CommunityToken is ERC721, ERC721URIStorage, ERC721Burnable, Ownable, TokenTransferRequest {
    uint256 private _nextTokenId;

    error NotApprovedForTransfer();
    error OnlyTokenOwner();
    error NotACommunityMember();

    // after deployment the ownership is transferred to CommunityRegistry contract
    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
        Ownable(msg.sender)
    {}

    // the owner of this contract is the CommunityRegistry contract
    // through the community contract the mint, burn and transfer of tokens is controlled
    function safeMint(address to, string memory uri) public onlyOwner returns(uint256) {
        uint256 tokenId = ++_nextTokenId;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

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

    function initiateTransfer(address from, address to, uint256 tokenId) public {
        if (msg.sender != IERC721(address(this)).ownerOf(tokenId)) revert OnlyTokenOwner();
        _initiateTransfer(from, to, tokenId);
    }

    function approveTransfer(uint256 tokenId) public {
        _approveTransfer(tokenId);
        // TODO: enforce only community members can approve transfer
    }

    // The following functions are overrides required to guard against freely transferring tokens
    // Token transfers must first be initiated by the owner and approved by another member
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        if (!isApproved(tokenId)) revert NotApprovedForTransfer();
        _executeTransfer(tokenId);
        super.transferFrom(from, to, tokenId);
    }
}
