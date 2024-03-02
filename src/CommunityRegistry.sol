// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {CommunityToken} from "./CommunityToken.sol";

contract CommunityRegistry is Ownable {
    mapping(address => uint256) private memberships;

    error MemberAlreadyInCommunity(address member);
    error MemberNotInCommunity(address member);

    constructor(address initialAdmin) Ownable(initialAdmin) {}

    modifier onlyNew(address member) {
        if (memberships[member] != 0) revert MemberAlreadyInCommunity(member);
        _;
    }

    modifier onlyExisting(address member) {
        if (memberships[member] == 0) revert MemberNotInCommunity(member);
        _;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // NFT is mintet to the registry contract and uri tracks the member info
    function addMemberToCommunity(address member, CommunityToken community, string memory uri) public onlyOwner onlyNew(member) {
        uint256 tokenId = community.safeMint(address(this), uri);
        memberships[member] = tokenId;
    }

    function removeMemberFromCommunity(address member, CommunityToken community) public onlyOwner onlyExisting(member) {
        uint256 tokenId = memberships[member];
        community.burn(tokenId);
        delete memberships[member];
    }

    function getMemberInfo(address member, CommunityToken community) public view returns (string memory) {
        uint256 tokenId = memberships[member];
        if (tokenId == 0) return "";
        return community.tokenURI(tokenId);
    }
}
