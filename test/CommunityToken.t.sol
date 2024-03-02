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
contract CommunityTokenTest is Test {
    DeployPenaltyGame deployer;

    CommunityToken communityToken;
    TokenTransferRequest tokenTransferRequest;
    TokenPool tokenPool;
    CommunityRegistry communityRegistry; // CommunityRegistry is the owner of CommunityToken, TokenTransferRequest, and TokenPool

    address public member1 = makeAddr("member1");
    address public member2 = makeAddr("member2");
    address public admin = makeAddr("admin");

    function setUp() public {
        deployer = new DeployPenaltyGame();
        (communityToken, tokenTransferRequest, tokenPool, communityRegistry, ) = deployer.run(admin);
    }

    function testAddMemberToCommunity() public {
        vm.prank((admin));
        communityRegistry.addMemberToCommunity(member1, communityToken, "uri1");
        string memory uri = communityRegistry.getMemberInfo(member1, communityToken);
        assertEq(uri, "uri1");
    }

    function testRemoveMemberFromCommunity() public {
        vm.startPrank((admin));
        communityRegistry.addMemberToCommunity(member1, communityToken, "uri1");
        string memory uriBeforeRemove = communityRegistry.getMemberInfo(member1, communityToken);
        communityRegistry.removeMemberFromCommunity(member1, communityToken);
        string memory uriAfterRemove = communityRegistry.getMemberInfo(member1, communityToken);
        
        assertEq(uriBeforeRemove, "uri1");
        assertEq(uriAfterRemove, "");
    }
}
