// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {CommunityToken} from "./CommunityToken.sol";


/**
 * @title CommunityRegistry
 * @author Sami Gabor
 * @notice This contract is responsible for managing the overall system:
 * - creation of tokens associated with communities
 * - assignment of tokens to members
 * - removal of members from communities
 */
contract CommunityRegistry is Ownable {
    mapping(address member => mapping(CommunityToken community => uint256 tokenId)) private memberships;

    error MemberAlreadyInCommunity(address member, CommunityToken community);
    error MemberNotInCommunity(address member, CommunityToken community);

    constructor(address initialAdmin) Ownable(initialAdmin) {}

    modifier onlyNew(address member, CommunityToken community) {
        if (isInCommunity(member, community)) revert MemberAlreadyInCommunity(member, community);
        _;
    }

    modifier onlyExisting(address member, CommunityToken community) {
        if (!isInCommunity(member, community)) revert MemberNotInCommunity(member, community);
        _;
    }

    // ERC721Receiver interface
    // This is required to receive the token from the community contract
    // It ensures a transfer mechanism is in place and the token is not be lost if transferred to the registry contract
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // NFT is mintet to the registry contract
    function createCommunityToken(CommunityToken community) public onlyOwner returns (uint256){
        uint256 tokenId = community.safeMint(address(this), "uri");
        return tokenId;
    }

    function assignTokenToMember(CommunityToken community, address member, uint256 tokenId) public onlyOwner onlyNew(member, community) {
        memberships[member][community] = tokenId;
        // transfer the token to the member
        community.transferFrom(address(this), member, tokenId);
        // community.approve(address(this), tokenId);
    }

    /**
     * @notice Removes a member from the community
     * The member is still the owner of the token. The token is not burned.
     * For burning the token, member can transfer it to the PoolToken contract
     * @param member The address of the member to remove
     * @param community The community token contract
     */
    function removeMemberFromCommunity(address member, CommunityToken community) public onlyOwner onlyExisting(member, community) returns (uint256){
        uint256 tokenId = memberships[member][community];
        delete memberships[member][community];
        return tokenId;
    }

    //////////////////////////////////////
    // View Functions                   //
    //////////////////////////////////////

    function isInCommunity(address member, CommunityToken community) public view returns (bool) {
        return memberships[member][community] != 0;
    }
}
