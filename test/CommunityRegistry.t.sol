// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployPenaltyGame} from "../script/DeployPenaltyGame.s.sol";
import {CommunityToken} from "../src/CommunityToken.sol";
import {TokenTransferRequest} from "../src/TokenTransferRequest.sol";
import {CommunityRegistry} from "../src/CommunityRegistry.sol";
import {TokenPool} from "../src/TokenPool.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

/**
 * forge test --fork-url $RPC_URL
 */
contract CommunityRegistryTest is Test {
    DeployPenaltyGame deployer;

    CommunityToken communityToken;
    TokenTransferRequest tokenTransferRequest;
    TokenPool tokenPool;
    CommunityRegistry communityRegistry; // CommunityRegistry is the owner of CommunityToken, TokenTransferRequest, and TokenPool
    HelperConfig helperConfig;

    address public from;
    address public to;
    address public approver;
    address public admin;

    uint256 tokenId;

    modifier createAndAssignTokenToMember() {
        _createAndAssignTokenTo(from);
        _;
    }

    function _createAndAssignTokenTo(address member) private {
        vm.startPrank(admin);
        tokenId = communityRegistry.createCommunityToken(address(communityToken));
        communityRegistry.assignTokenToMember(communityToken, member, tokenId);
        vm.stopPrank();
    }

    function setUp() public {
        deployer = new DeployPenaltyGame();
        (communityToken, tokenTransferRequest, tokenPool, communityRegistry, helperConfig) = deployer.run();
        (, admin, from, to, approver) = helperConfig.config();
        _createAndAssignTokenTo(approver);
    }

    //////////////////////////////////////
    // Community Registry               //
    //////////////////////////////////////

    function testIsInCommunity() public createAndAssignTokenToMember {
        assertEq(communityRegistry.isInCommunity(from, communityToken), true);
    }

    function testIsNotInCommunity() public {
        assertEq(communityRegistry.isInCommunity(from, communityToken), false);
    }

    function testCreateCommunityToken() public {
        vm.prank((admin));
        tokenId = communityRegistry.createCommunityToken(address(communityToken));
        assertEq(communityToken.ownerOf(tokenId), address(communityRegistry));
    }

    function testAssignTokenToMember() public createAndAssignTokenToMember {
        // member is still the owner of the token, but is in the community anymore
        assertEq(communityToken.ownerOf(tokenId), from);
        assertEq(communityRegistry.isInCommunity(from, communityToken), true);
    }

    function testRemoveMemberFromCommunity() public createAndAssignTokenToMember {
        vm.prank(admin);
        communityRegistry.removeMemberFromCommunity(from, communityToken);
        // member is still the owner of the token, but is not in the community anymore
        assertEq(communityToken.ownerOf(tokenId), from);
        assertEq(communityRegistry.isInCommunity(from, communityToken), false);
    }

    function testBurnByAdmin() public createAndAssignTokenToMember {
        to = address(tokenPool);
        vm.prank(from);
        communityToken.initiateTransferRequest(to, tokenId);
        vm.prank(approver);
        communityToken.approveTransferRequest(tokenId);
        vm.prank(from);
        communityToken.completeTransferRequest(tokenId);

        vm.prank(admin);
        communityRegistry.burnCommunityToken(communityToken, tokenId);
    }

    function testBurnByMember() public createAndAssignTokenToMember {
        // TBD: Members are allowed to burn their own token? Or enforce "only burn from pool" mechanism?
        vm.prank(from);
        communityToken.burn(tokenId);
    }

    //////////////////////////////////////
    // Community Token                  //
    //////////////////////////////////////

    function testInitiateTransferRequest() public createAndAssignTokenToMember {
        vm.prank(from);
        communityToken.initiateTransferRequest(to, tokenId);
    }
    
    function testApproveTransferRequest() public createAndAssignTokenToMember {
        vm.prank(from);
        communityToken.initiateTransferRequest(to, tokenId);
        
        vm.prank(approver);
        communityToken.approveTransferRequest(tokenId);
    }

    function testCompleteTransferRequest() public createAndAssignTokenToMember {
        vm.prank(from);
        communityToken.initiateTransferRequest(to, tokenId);
        vm.prank(approver);
        communityToken.approveTransferRequest(tokenId);

        vm.prank(from);
        communityToken.completeTransferRequest(tokenId);
    }

    function testCompleteTransferRequestWithoutCallingComplete() public createAndAssignTokenToMember {
        vm.prank(from);
        communityToken.initiateTransferRequest(to, tokenId);
        vm.prank(approver);
        communityToken.approveTransferRequest(tokenId);

        vm.prank(from);
        communityToken.safeTransferFrom(from, to, tokenId);
    }

    function testCompleteTransferRequestToPool() public createAndAssignTokenToMember {
        to = address(tokenPool);
        vm.prank(from);
        communityToken.initiateTransferRequest(to, tokenId);
        vm.prank(approver);
        communityToken.approveTransferRequest(tokenId);

        vm.prank(from);
        communityToken.completeTransferRequest(tokenId);
    }

    function testRevertTransferRequestIfNotInitiated() public createAndAssignTokenToMember {
        vm.prank(approver);
        vm.expectRevert(); // TODO: Encode revert message
        communityToken.approveTransferRequest(tokenId);
    }

    function testRevertTransferRequestIfNotApproved() public createAndAssignTokenToMember {
        vm.startPrank(from);
        communityToken.initiateTransferRequest(to, tokenId);
        vm.expectRevert(); // TODO: Encode revert message
        communityToken.completeTransferRequest(tokenId);
        vm.stopPrank();
    }
}
