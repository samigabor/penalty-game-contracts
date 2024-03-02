// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import {CommunityToken} from "./CommunityToken.sol";

contract TokenPool is Ownable {
    // after deployment the ownership is transferred to CommunityRegistry contract
    constructor() Ownable(msg.sender) {}

    function burnTokens(address tokenAddress, uint256 tokenId) external onlyOwner {
        CommunityToken token = CommunityToken(tokenAddress);
        token.burn(tokenId);
    }
}
