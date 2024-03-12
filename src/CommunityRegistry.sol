// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {CommunityToken} from "./CommunityToken.sol";
import {TokenPool} from "./TokenPool.sol";
import {RequestStatus} from "./TokenTransferRequest.sol";

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
contract CommunityRegistry is Ownable {
    TokenPool public tokenPool;
    mapping(address member => mapping(CommunityToken community => uint256 tokenId)) private memberships;
    CommunityToken[] public communities;
    mapping(address => CommunityToken[]) public communitiesByAdmin; // one admin can manage multiple communities
    mapping(CommunityToken => address) public communityAdmins;

    event CommunityDeployed(CommunityToken community, address admin);
    event CommunityTokenMinted(CommunityToken community, uint256 tokenId);
    event MemberAssignedToCommunity(address member, CommunityToken community, uint256 tokenId);
    event MemberRemovedFromCommunity(address member, CommunityToken community, uint256 tokenId);

    error OnlyCommunityAdmin();
    error MemberAlreadyInCommunity(address member, CommunityToken community);
    error MemberNotInCommunity(address member, CommunityToken community);
    error CommunityRegistryDoesNotAcceptTokenTransfers();

    constructor(TokenPool _pool, address initialAdmin) Ownable(initialAdmin) { // address communityTemplate
        tokenPool = _pool;
    }

    modifier onlyCommunityAdmin(CommunityToken community, address admin) {
        if (communityAdmins[community] != admin) revert OnlyCommunityAdmin();
        _;
    }

    modifier onlyNew(address member, CommunityToken community) {
        if (isInCommunity(member, community)) revert MemberAlreadyInCommunity(member, community);
        _;
    }

    modifier onlyExisting(address member, CommunityToken community) {
        if (!isInCommunity(member, community)) revert MemberNotInCommunity(member, community);
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
    function mintTokenToMember(CommunityToken community, address member) external onlyCommunityAdmin(community, msg.sender) {
        uint256 tokenId = _mintCommunityToken(community);
        _assignTokenToMember(community, member, tokenId);
    }

    /**
     * @notice Creates a new token for a community
     * The token is owned by the registry contract
     * @param community The community token contract
     * @return The id of the created token
     */
    function mintCommunityToken(CommunityToken community) external onlyOwner returns (uint256){
        return _mintCommunityToken(community);
    }

    /**
     * @notice Assigns a token to a member
     * The token ownership is transferred to the member
     * @param member The address of the member to assign the token to
     * @param community The community token contract
     * @param tokenId The id of the token to assign
     */
    function assignTokenToMember(CommunityToken community, address member, uint256 tokenId) external onlyOwner onlyNew(member, community) {
        _assignTokenToMember(community, member, tokenId);
    }

    /**
     * @notice Removes a member from the community
     * The member is still the owner of the token. The token is not burned.
     * For burning the token, member can transfer it to the PoolToken contract
     * @param member The address of the member to remove
     * @param community The community token contract
     */
    function removeMemberFromCommunity(address member, CommunityToken community) external onlyOwner onlyExisting(member, community) returns (uint256){
        return _removeMemberFromCommunity(member, community);
    }

    /**
     * @notice Burn a community token from the pool
     * The registry contract is the owner the pool contract, so this methos is neeeded for burning tokens transferred to the pool
     * @param community The community token contract
     * @param tokenId The id of the token to burn
     */
    function burnCommunityToken(CommunityToken community, uint256 tokenId) external onlyOwner {
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

        // TODO: remove the need for request update if called from this contract
        community.updateRequestStatus(tokenId, RequestStatus.Pending, member);
        community.updateRequestStatus(tokenId, RequestStatus.Approved, address(0));

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
