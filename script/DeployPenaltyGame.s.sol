// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {CommunityToken} from "../src/CommunityToken.sol";
import {TokenTransferRequest} from "../src/TokenTransferRequest.sol";
import {CommunityRegistry} from "../src/CommunityRegistry.sol";
import {TokenPool} from "../src/TokenPool.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

address constant COMMUNITY_TOKEN_ADDRESS = 0x121fe9DA9be9fC948bF56F93F99c13ccb2cFE36d;
address constant TOKEN_POOL_ADDRESS = 0x4432C7E4972a84E20E1FB0D899e61287c522e2dB;
address constant COMMUNITY_REGISTRY_ADDRESS = 0xd359AA2364b1F3716dc1CC96bb2Fa4ef19bc97d4;

// deployed but not used in this script
// address constant TRANSFER_REQUEST_TOKEN_ADDRESS = 0x29BC83517ba99dB62e44d4D2dB3BF60093b17110;
// address constant HELPER_CONFIG_ADDRESS = 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141;

/**
 * @dev Deploy to anvil
    forge script script/DeployPenaltyGame.s.sol \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast

 * @dev Script to deploy all contracts and transfer ownership to CommunityRegistry:
    forge script script/DeployPenaltyGame.s.sol \
    --rpc-url $RPC_URL_SEPOLIA \
    --optimizer-runs 200 \
    --broadcast \
    --watch \
    --private-key=$PRIVATE_KEY

 * @dev Manual deployment example:
    forge create \
    --rpc-url $RPC_URL_SEPOLIA \
    --optimizer-runs 200 \
    --constructor-args "Penalty Game" "PG" \
    --private-key $PRIVATE_KEY \
    src/CommunityToken.sol:CommunityToken

    forge create \
    --rpc-url $RPC_URL_SEPOLIA \
    --optimizer-runs 200 \
    --constructor-args 0x4432C7E4972a84E20E1FB0D899e61287c522e2dB 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3 \
    --private-key $PRIVATE_KEY \
    src/CommunityRegistry.sol:CommunityRegistry

 * @dev Manual Verification required for each contract:
    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(string,string,address)" "Penalty Game" "PG" 0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2) \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0xDd88659C8d77b092cd6B68459A86f33F123E2B47 \
    src/CommunityToken.sol:CommunityToken

    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5 \
    src/TokenPool.sol:TokenPool

    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0x77Dcd2922138F77cc53B7296c86f297B9CC07F83 \
    src/TokenTransferRequest.sol:TokenTransferRequest

    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address,address)" 0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3) \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2 \
    src/CommunityRegistry.sol:CommunityRegistry
 */
contract DeployPenaltyGame is Script {

    function run() external returns (CommunityToken communityToken, TokenTransferRequest tokenTransferRequest, TokenPool tokenPool, CommunityRegistry communityRegistry, HelperConfig helperConfig) {
        helperConfig = new HelperConfig();
        (uint256 deployerKey, address admin, , , ) = helperConfig.config();
        
        vm.startBroadcast(deployerKey);
        tokenTransferRequest = new TokenTransferRequest();
        tokenPool = new TokenPool();
        communityRegistry = new CommunityRegistry(tokenPool, admin);
        communityToken = communityRegistry.deployCommunityContract("Penalty Game", "PG");
        tokenPool.transferOwnership(address(communityRegistry));

        vm.stopBroadcast();

        return (communityToken, tokenTransferRequest, tokenPool, communityRegistry, helperConfig);
    }
}
