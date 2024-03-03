// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployPenaltyGame} from "../script/DeployPenaltyGame.s.sol";
import {CommunityToken} from "../src/CommunityToken.sol";
import {TokenTransferRequest} from "../src/TokenTransferRequest.sol";
import {CommunityRegistry} from "../src/CommunityRegistry.sol";
import {TokenPool} from "../src/TokenPool.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * forge test --fork-url $RPC_URL
 */
contract CommunityRegistryTest is Test {
    DeployPenaltyGame deployer;

    CommunityToken communityToken;
    TokenTransferRequest tokenTransferRequest;
    TokenPool tokenPool;
    CommunityRegistry communityRegistry; // CommunityRegistry is the owner of CommunityToken, TokenTransferRequest, and TokenPool

    address public member = makeAddr("member");
    address public admin = makeAddr("admin");

    function setUp() public {
        deployer = new DeployPenaltyGame();
        (communityToken, tokenTransferRequest, tokenPool, communityRegistry, ) = deployer.run(admin);
    }

    function testCreateCommunityToken() public {
        vm.prank((admin));
        uint256 tokenId = communityRegistry.createCommunityToken(communityToken);
        assertEq(communityToken.ownerOf(tokenId), address(communityRegistry));
    }

    function testAssignTokenToMember() public {
        vm.startPrank((admin));
        uint256 tokenId = communityRegistry.createCommunityToken(communityToken);
        communityRegistry.assignTokenToMember(communityToken, member, tokenId);
        vm.stopPrank();
        // member is still the owner of the token, but is in the community anymore
        assertEq(communityToken.ownerOf(tokenId), member);
        assertEq(communityRegistry.isInCommunity(member, communityToken), true);
    }

    function testRemoveMemberFromCommunity() public {
        vm.startPrank((admin));
        uint256 tokenId = communityRegistry.createCommunityToken(communityToken);
        communityRegistry.assignTokenToMember(communityToken, member, tokenId);
        communityRegistry.removeMemberFromCommunity(member, communityToken);
        vm.stopPrank();
        // member is still the owner of the token, but is not in the community anymore
        assertEq(communityToken.ownerOf(tokenId), member);
        assertEq(communityRegistry.isInCommunity(member, communityToken), false);
    }
}
