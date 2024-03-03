// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {CommunityToken} from "./CommunityToken.sol";
import {TokenPool} from "./TokenPool.sol";

// Order Layout
// Type declarations
// State variables
// Events
// Errors
// Modifiers
// Functions

// Orfer of functions
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private

/**
 * @title CommunityRegistry
 * @author Sami Gabor
 * @notice This contract is responsible for managing the overall system:
 * - creation of tokens associated with communities
 * - assignment of tokens to members
 * - removal of members from communities
 */
contract CommunityRegistry is Ownable {
    TokenPool public tokenPool;
    mapping(address member => mapping(CommunityToken community => uint256 tokenId)) private memberships;

    event CommunityTokenCreated(CommunityToken community, uint256 tokenId);
    event MemberAssignedToCommunity(address member, CommunityToken community, uint256 tokenId);
    event MemberRemovedFromCommunity(address member, CommunityToken community, uint256 tokenId);

    error MemberAlreadyInCommunity(address member, CommunityToken community);
    error MemberNotInCommunity(address member, CommunityToken community);
    error CommunityRegistryDoesNotAcceptTokenTransfers();

    constructor(TokenPool _pool, address initialAdmin) Ownable(initialAdmin) {
        tokenPool = _pool;
    }

    modifier onlyNew(address member, CommunityToken community) {
        if (isInCommunity(member, community)) revert MemberAlreadyInCommunity(member, community);
        _;
    }

    modifier onlyExisting(address member, CommunityToken community) {
        if (!isInCommunity(member, community)) revert MemberNotInCommunity(member, community);
        _;
    }

    /**
     * @notice ERC721Receiver interface
     * Allows minting tokens to this contract and guards against receiving tokens using safeTransfeFrom
     * @param from The address which previously owned the token
     * @return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
     * @dev params: from, to, tokenId, data
     */
    function onERC721Received(address from, address, uint256, bytes calldata) external view returns (bytes4) {
        if (from != address(this)) revert CommunityRegistryDoesNotAcceptTokenTransfers();
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @notice Creates a new token for a community
     * The token is owned by the registry contract
     * @param community The community token contract
     * @return The id of the created token
     */
    function createCommunityToken(CommunityToken community) public onlyOwner returns (uint256){
        uint256 tokenId = community.safeMint(address(this), "uri");
        emit CommunityTokenCreated(community, tokenId);
        return tokenId;
    }

    /**
     * @notice Assigns a token to a member
     * The token ownership is transferred to the member
     * @param member The address of the member to assign the token to
     * @param community The community token contract
     * @param tokenId The id of the token to assign
     */
    function assignTokenToMember(CommunityToken community, address member, uint256 tokenId) public onlyOwner onlyNew(member, community) {
        memberships[member][community] = tokenId;
        community.safeTransferFrom(address(this), member, tokenId);
        emit MemberAssignedToCommunity(member, community, tokenId);
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
        emit MemberRemovedFromCommunity(member, community, tokenId);
        return tokenId;
    }

    /**
     * @notice Burn a community token from the pool
     * The registry contract is the owner the pool contract, so this methos is neeeded for burning tokens transferred to the pool
     * @param community The community token contract
     * @param tokenId The id of the token to burn
     */
    function burnCommunityToken(CommunityToken community, uint256 tokenId) public onlyOwner {
        tokenPool.burnCommunityToken(community, tokenId);
    }

    //////////////////////////////////////
    // View Functions                   //
    //////////////////////////////////////

    /**
     * @notice Checks if a member is in a community
     * @param member The address of the member
     * @param community The community token contract
     * @return True if the member is in the community, false otherwise
     */
    function isInCommunity(address member, CommunityToken community) public view returns (bool) {
        return memberships[member][community] != 0;
    }
}
