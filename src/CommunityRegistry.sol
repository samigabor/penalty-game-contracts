// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {CommunityToken} from "./CommunityToken.sol";
import {TokenPool} from "./TokenPool.sol";
import {TokenTransferRequest} from "./TokenTransferRequest.sol";

/**
 * @title CommunityRegistry
 * @author Sami Gabor
 * @notice This contract is responsible for managing the overall system.
 * Through this contract admins and members interact with the system, allowing them to:
 * - create community token contracts
 * - create tokens associated with communities
 * - assign tokens to members
 * - remove members from communities
 */
contract CommunityRegistry is Ownable, TokenTransferRequest {
    TokenPool public tokenPool;
    mapping(address member => mapping(CommunityToken community => uint256 tokenId)) private memberships; // TODO: does NOT track transferred tokens/memberships
    CommunityToken[] public communities;
    mapping(address => CommunityToken[]) public communitiesByAdmin; // one admin can manage multiple communities
    mapping(CommunityToken => address) public communityAdmins;

    event CommunityDeployed(CommunityToken community, address admin);
    event CommunityTokenMinted(CommunityToken community, uint256 tokenId);
    event MemberAssignedToCommunity(address member, CommunityToken community, uint256 tokenId);
    event MemberRemovedFromCommunity(address member, CommunityToken community, uint256 tokenId);

    error OnlyCommunityAdmin();
    error NotTheTokenOwner(address owner, address sender, uint256 tokenId);
    error MemberAlreadyInCommunity(address member, CommunityToken community);
    error MemberNotInCommunity(address member, CommunityToken community);
    error CommunityRegistryDoesNotAcceptTokenTransfers();
    error TransferFailed(address from, address to, uint256 tokenId);

    constructor(TokenPool _pool, address initialAdmin) Ownable(initialAdmin) { // address communityTemplate
        tokenPool = _pool;
    }

    modifier onlyCommunityAdmin(CommunityToken community) {
        if (communityAdmins[community] != msg.sender) revert OnlyCommunityAdmin();
        _;
    }

    modifier onlyNew(CommunityToken community, address member) {
        if (isInCommunity(member, community)) revert MemberAlreadyInCommunity(member, community);
        _;
    }

    modifier onlyExisting(CommunityToken community, address member) {
        if (!isInCommunity(member, community)) revert MemberNotInCommunity(member, community);
        _;
    }

    modifier onlyTokenOwner(CommunityToken community, uint256 tokenId) {
        address tokenOwner = CommunityToken(community).ownerOf(tokenId);
        if (tokenOwner != msg.sender) revert NotTheTokenOwner(tokenOwner, msg.sender, tokenId);
        _;
    }

    //////////////////////////////////////
    // Safe ERC721 Transfers            //
    //////////////////////////////////////

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

    //////////////////////////////////////
    // External Functions               //
    //////////////////////////////////////

    /**
     * @notice Deploys a new community token contract
     * The contract is owned by the registry contract
     * @param name The name of the community
     * @param symbol The symbol of the community
     * @return community The address of the deployed community token contract
     */
    function deployCommunityContract(string memory name, string memory symbol) external returns (CommunityToken community) {
        return _deployCommunityContract(name, symbol);
    }

    /**
     * @notice Mints a new token for a community and assigns it to a member
     * The token is owned by the member
     * @param community The community token contract
     * @param member The address of the member to assign the token to
     */
    function mintTokenToMember(CommunityToken community, address member) external onlyCommunityAdmin(community) {
        uint256 tokenId = _mintCommunityToken(community);
        _assignTokenToMember(community, member, tokenId);
    }

    /**
     * @notice Creates a new token for a community
     * The token is owned by the registry contract
     * @param community The community token contract
     * @return The id of the created token
     */
    function mintCommunityToken(CommunityToken community) external onlyCommunityAdmin(community) returns (uint256){
        return _mintCommunityToken(community);
    }

    /**
     * @notice Assigns a token, held by the registry, to a member
     * The token ownership is transferred to the member
     * @param member The address of the member to assign the token to
     * @param community The community token contract
     * @param tokenId The id of the token to assign
     */
    function assignTokenToMember(CommunityToken community, address member, uint256 tokenId) external onlyCommunityAdmin(community) onlyNew(community, member) {
        _assignTokenToMember(community, member, tokenId);
    }

    /**
     * @notice Initiates a transfer request for a token
     * The request is pending until it is approved by a community admin
     * @param community The community token contract
     * @param to The address of the member to transfer the token to
     * @param tokenId The id of the token to be transferred
     */
    function initiateTransferRequest(CommunityToken community, address to, uint256 tokenId) external onlyTokenOwner(community, tokenId) {
        _initiateTransferRequest(address(community), to, tokenId);
    }

    /**
     * @notice Approves a transfer request for a token
     * The request must be pending to be approved
     * @param community The community token contract
     * @param tokenId The id of the token to be transferred
     */
    function approveTransferRequest(CommunityToken community, uint256 tokenId) external onlyExisting(community, msg.sender) {
        _approveTransferRequest(address(community), tokenId);
    }

    /**
     * @notice Completes a transfer request for a token and transfers the token to the new owner
     * The request must be approved to be completed (i.e. by a community member)
     * @param community The community token contract
     * @param tokenId The id of the token to be transferred
     */
    function completeTransferRequest(CommunityToken community, uint256 tokenId) external onlyTokenOwner(community, tokenId) {
        _completeTransferRequest(address(community), tokenId);
        (bool success, ) = address(community).call(abi.encode(msg.sender, _transferRequests[address(community)][tokenId].to, tokenId));
        if (!success) revert TransferFailed(msg.sender, _transferRequests[address(community)][tokenId].to, tokenId);
    }

    /**
     * @notice Removes a member from the community
     * The member is still the owner of the token. The token is not burned.
     * For burning the token, member can transfer it to the PoolToken contract
     * @param member The address of the member to remove
     * @param community The community token contract
     */
    function removeMemberFromCommunity(address member, CommunityToken community) external onlyCommunityAdmin(community) onlyExisting(community, member) returns (uint256){
        return _removeMemberFromCommunity(member, community);
    }

    /**
     * @notice Burn a community token from the pool
     * The registry contract is the owner the pool contract, so this methos is neeeded for burning tokens transferred to the pool
     * @param community The community token contract
     * @param tokenId The id of the token to burn
     */
    function burnCommunityToken(CommunityToken community, uint256 tokenId) external onlyCommunityAdmin(community) {
        _burnCommunityToken(community, tokenId);
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

    /**
     * @notice Get community info
     * @return All community token contracts, their names, symbols and admins
     */
    function getCommunities() external view returns (CommunityToken[] memory, string[] memory, string[] memory, address[] memory) {
        string[] memory names = new string[](communities.length);
        string[] memory symbols = new string[](communities.length);
        address[] memory admins = new address[](communities.length);
        for (uint256 i = 0; i < communities.length; i++) {
            names[i] = communities[i].name();
            symbols[i] = communities[i].symbol();
            admins[i] = communityAdmins[communities[i]];
        }
        return (communities, names, symbols, admins);
    }

    //////////////////////////////////////
    // Private Functions                //
    //////////////////////////////////////

    function _deployCommunityContract(string memory name, string memory symbol) private returns (CommunityToken community) {
        community = new CommunityToken(name, symbol, address(this));
        communitiesByAdmin[msg.sender].push(community);
        communityAdmins[community] = msg.sender;
        communities.push(community); // not an efficient way to track communities, but acceptable until subgraphs are implemented
        emit CommunityDeployed(community, msg.sender);
    }

    function _mintCommunityToken(CommunityToken community) private returns (uint256){
        uint256 tokenId = CommunityToken(community).safeMint(address(this), "uri");
        emit CommunityTokenMinted(community, tokenId);
        return tokenId;
    }

    function _assignTokenToMember(CommunityToken community, address member, uint256 tokenId) private {
        memberships[member][community] = tokenId;
        community.safeTransferFrom(address(this), member, tokenId);
        emit MemberAssignedToCommunity(member, community, tokenId);
    }

    function _removeMemberFromCommunity(address member, CommunityToken community) private returns (uint256){
        uint256 tokenId = memberships[member][community];
        delete memberships[member][community];
        emit MemberRemovedFromCommunity(member, community, tokenId);
        return tokenId;
    }

    function _burnCommunityToken(CommunityToken community, uint256 tokenId) private {
        tokenPool.burnCommunityToken(community, tokenId);
    }
}
