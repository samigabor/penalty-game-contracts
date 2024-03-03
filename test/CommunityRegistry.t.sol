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
    address public other = makeAddr("other");
    address public admin = makeAddr("admin");

    uint256 tokenId;

    modifier createAndAssignTokenToMember() {
        vm.startPrank(admin);
        tokenId = communityRegistry.createCommunityToken(communityToken);
        communityRegistry.assignTokenToMember(communityToken, member, tokenId);
        vm.stopPrank();
        _;
    }

    function setUp() public {
        deployer = new DeployPenaltyGame();
        (communityToken, tokenTransferRequest, tokenPool, communityRegistry, ) = deployer.run(admin);
    }

    function testCreateCommunityToken() public {
        vm.prank((admin));
        tokenId = communityRegistry.createCommunityToken(communityToken);
        assertEq(communityToken.ownerOf(tokenId), address(communityRegistry));
    }

    function testAssignTokenToMember() public createAndAssignTokenToMember {
        // member is still the owner of the token, but is in the community anymore
        assertEq(communityToken.ownerOf(tokenId), member);
        assertEq(communityRegistry.isInCommunity(member, communityToken), true);
    }

    function testRemoveMemberFromCommunity() public createAndAssignTokenToMember {
        vm.prank(admin);
        communityRegistry.removeMemberFromCommunity(member, communityToken);
        // member is still the owner of the token, but is not in the community anymore
        assertEq(communityToken.ownerOf(tokenId), member);
        assertEq(communityRegistry.isInCommunity(member, communityToken), false);
    }

    function testMemberCanTransferApprovedTokenToPool() public createAndAssignTokenToMember {
        vm.prank(member);
        communityToken.initiateTransfer(member, address(tokenPool), tokenId);

        vm.prank(other);
        communityToken.approveTransfer(tokenId);

        vm.prank(member);
        communityToken.transferFrom(member, address(tokenPool), tokenId);
    }

    function testMemberCanNotTransferNonApprovedTokenToPool() public createAndAssignTokenToMember {
        vm.startPrank(member);
        communityToken.initiateTransfer(member, address(tokenPool), tokenId);
        vm.expectRevert(CommunityToken.NotApprovedForTransfer.selector);
        communityToken.transferFrom(member, address(tokenPool), tokenId);
        vm.stopPrank();
    }

    function testMemberCanSafeTransferTokenToPool() public createAndAssignTokenToMember {
        vm.prank(member);
        communityToken.initiateTransfer(member, address(tokenPool), tokenId);
        vm.prank(other);
        communityToken.approveTransfer(tokenId);
        vm.prank(member);
        communityToken.safeTransferFrom(member, address(tokenPool), tokenId);
        // member is not the owner of the token anymore
        assertEq(communityToken.ownerOf(tokenId), address(tokenPool));
    }

    function testMemberCanTransferTokenToOther() public createAndAssignTokenToMember {
        vm.prank(member);
        communityToken.initiateTransfer(member, other, tokenId);
        vm.prank(other);
        communityToken.approveTransfer(tokenId);
        vm.prank(member);
        communityToken.transferFrom(member, other, tokenId);
        // member is not the owner of the token anymore
        assertEq(communityToken.ownerOf(tokenId), other);
    }

    function testMemberCanSafeTransferTokenToOther() public createAndAssignTokenToMember {
        vm.prank(member);
        communityToken.initiateTransfer(member, other, tokenId);
        vm.prank(other);
        communityToken.approveTransfer(tokenId);
        vm.prank(member);
        communityToken.safeTransferFrom(member, other, tokenId);
        // member is not the owner of the token anymore
        assertEq(communityToken.ownerOf(tokenId), other);
    }

    function testBurnCommunityToken() public createAndAssignTokenToMember {
        vm.prank(member);
        communityToken.initiateTransfer(member, address(tokenPool), tokenId);
        vm.prank(other);
        communityToken.approveTransfer(tokenId);
        vm.prank(member);
        communityToken.safeTransferFrom(member, address(tokenPool), tokenId);

        vm.prank(admin);
        communityRegistry.burnCommunityToken(communityToken, tokenId);
    }

    function testRevertBurnByNonPool() public createAndAssignTokenToMember {
        vm.prank(member);
        communityToken.burn(tokenId);
        // TBD: Enforce "only burn from pool" mechanism!?
    }

    // CommunityToken tests

    function testInitiateTransfer() public createAndAssignTokenToMember {
        vm.startPrank(member);
        communityToken.initiateTransfer(member, other, tokenId);
        assertEq(communityToken.ownerOf(tokenId), member);
        assertEq(communityToken.isApproved(tokenId), false);
    }

    function testApproveTransfer() public createAndAssignTokenToMember {
        vm.prank(member);
        communityToken.initiateTransfer(member, other, tokenId);

        vm.prank(other);
        communityToken.approveTransfer(tokenId);

        assertEq(communityToken.ownerOf(tokenId), member);
        assertEq(communityToken.isApproved(tokenId), true);
    }
}
