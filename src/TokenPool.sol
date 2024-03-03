// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {CommunityToken} from "./CommunityToken.sol";

/**
 * @title TokenPool
 * @notice The pool is owned by the CommunityRegistry contract
 * @notice Members can renounce their community memberships by transferring their token to the pool
 * @notice Tokens transferred to the pool are blocked and cannot be transferred back, they can only be burned
 */
contract TokenPool is Ownable {
    event CommunityTokenReceived(address from, address to, uint256 tokenId, bytes data);
    event CommunityTokenBurned(CommunityToken from, uint256 tokenId);

    // after deployment the ownership is transferred to CommunityRegistry contract
    constructor() Ownable(msg.sender) {}

    /**
     * @notice ERC721Receiver interface
     * Guards against receiving tokens from other contracts, but allows minting tokens
     * @param from The address which previously owned the token
     * @param to The address which is the new owner of the token
     * @param tokenId The id of the token
     * @param data Additional data with no specified format
     * @return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
     */
    function onERC721Received(address from, address to, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        emit CommunityTokenReceived(from, to, tokenId, data);
        return IERC721Receiver.onERC721Received.selector;
    }

    function burnCommunityToken(CommunityToken community, uint256 tokenId) external onlyOwner {
        // community.approve(address(this), tokenId);
        community.burn(tokenId);
        emit CommunityTokenBurned(community, tokenId);
    }
}
