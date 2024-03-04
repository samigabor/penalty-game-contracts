// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {TokenTransferRequest, TransferRequest, RequestStatus} from "./TokenTransferRequest.sol";

contract CommunityToken is ERC721, ERC721URIStorage, ERC721Burnable, Ownable, TokenTransferRequest {
    uint256 private _nextTokenId;

    error OnlyTokenOwner(address owner, address sender, uint256 tokenId);
    error MemberNotInCommunity(address member);
    error UnableToCompleteTransferRequest(address from, address to, uint256 tokenId);


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

    // Override guards against freely transfering the tokens
    // Token transfers must first be initiated by the owner and approved by another member
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyApprovedRequest(tokenId) {
        super.transferFrom(from, to, tokenId);
        _updateRequestStatus(tokenId, RequestStatus.Completed, address(0));
    }

    /**
     * Update the status of a token transfer request.
     * Only CommunityRegistry contract is allowed to call this function.
     * @param tokenId The id of the token
     * @param status The new status of the token transfer request
     */
    // TODO: remove the need for request update if called from the registry
    function updateRequestStatus(uint256 tokenId, RequestStatus status, address to) public onlyOwner {
        _updateRequestStatus(tokenId, status, to);
    }

    function initiateTransferRequest(address to, uint256 tokenId) public {
        if (ownerOf(tokenId) != msg.sender) revert OnlyTokenOwner(ownerOf(tokenId), msg.sender, tokenId);
        _updateRequestStatus(tokenId, RequestStatus.Pending, to);
    }

    function approveTransferRequest(uint256 tokenId) public {
        // member can be removed from the community but still have a token => TODO: Check registry if member is in community (e.g. onlyExisting(msg.sender, address(this)))
        if (balanceOf(msg.sender) == 0) revert MemberNotInCommunity(msg.sender);
        _updateRequestStatus(tokenId, RequestStatus.Approved, address(0));
    }

    // convenience method. Transfer can be completed directly from the community token contract using transferFrom/safeTransferFrom
    function completeTransferRequest(uint256 tokenId) public {
        safeTransferFrom(msg.sender, _transferRequests[tokenId].to, tokenId);
    }

    /**
     * Get the status of a token transfer request.
     * @param tokenId The id of the token
     * @return The status of the token transfer request
     */
    function getTransferRequest(uint256 tokenId) public view returns (TransferRequest memory) {
        return _transferRequests[tokenId];
    }
}
