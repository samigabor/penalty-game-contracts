// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {CommunityToken} from "../src/CommunityToken.sol";
import {TokenTransferRequest} from "../src/TokenTransferRequest.sol";
import {CommunityRegistry} from "../src/CommunityRegistry.sol";
import {TokenPool} from "../src/TokenPool.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/**
forge script script/DeployPenaltyGame.s.sol --rpc-url http://127.0.0.1:8545 --broadcast

        forge script script/DeployPenaltyGame.s.sol \
        --rpc-url $RPC_URL \
        --broadcast \
        --private-key=$PRIVATE_KEY \
        --verify --etherscan-api-key $ETHERSCAN_API_KEY
 */
// RPC_URL=https://1rpc.io/sepolia
contract DeployPenaltyGame is Script {

    function run() external returns (CommunityToken communityToken, TokenTransferRequest tokenTransferRequest, TokenPool tokenPool, CommunityRegistry communityRegistry, HelperConfig helperConfig) {
        helperConfig = new HelperConfig();
        (uint256 deployerKey) = helperConfig.config();
        
        vm.startBroadcast(deployerKey);
        communityToken = new CommunityToken("Penalty Game", "PG");
        tokenTransferRequest = new TokenTransferRequest();
        tokenPool = new TokenPool();
        communityRegistry = new CommunityRegistry(tokenPool, makeAddr("admin"));

        communityToken.transferOwnership(address(communityRegistry));
        tokenPool.transferOwnership(address(communityRegistry));

        vm.stopBroadcast();

        return (communityToken, tokenTransferRequest, tokenPool, communityRegistry, helperConfig);
    }
}
