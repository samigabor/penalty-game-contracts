// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {CommunityToken} from "../src/CommunityToken.sol";
import {TokenTransferRequest} from "../src/TokenTransferRequest.sol";
import {CommunityRegistry} from "../src/CommunityRegistry.sol";
import {TokenPool} from "../src/TokenPool.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

address constant COMMUNITY_REGISTRY_ADDRESS = 0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372;
address constant COMMUNITY_TOKEN_ADDRESS = 0x07d8Cb502429483485ae3eaC4Ac8DA3E038b8b80;
address constant TOKEN_POOL_ADDRESS = 0xEa4e3Af80a3fb7d8C6fCaC9632034ab41170Da68;

// deployed but not used in this script
// address constant TRANSFER_REQUEST_TOKEN_ADDRESS = 0x2B6Bd7190eD74161C979623f9B5E6d02861Dda44;
// address constant HELPER_CONFIG_ADDRESS = 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141;

/**
 * @dev Deploy to anvil
    forge script script/DeployPenaltyGame.s.sol \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast

 * @dev Script to deploy all contracts and transfer ownership to CommunityRegistry:
    forge script script/DeployPenaltyGame.s.sol \
    --rpc-url $RPC_URL_POLYGON \
    --optimizer-runs 200 \
    --broadcast \
    --watch \
    --private-key=$PRIVATE_KEY

 * @dev Manual deployment example:
    forge create \
    --rpc-url $RPC_URL_SEPOLIA \
    --optimizer-runs 200 \
    --constructor-args "Penalty Game" "PG" 0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372 \
    --private-key $PRIVATE_KEY \
    src/CommunityToken.sol:CommunityToken

    forge create \
    --rpc-url $RPC_URL_SEPOLIA \
    --optimizer-runs 200 \
    --constructor-args 0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3 \
    --private-key $PRIVATE_KEY \
    src/CommunityRegistry.sol:CommunityRegistry

 * @dev Manual Verification required for each contract:
    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(string,string,address)" "Penalty Game" "PG" 0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372) \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0x07d8Cb502429483485ae3eaC4Ac8DA3E038b8b80 \
    src/CommunityToken.sol:CommunityToken

    forge verify-contract \
    --chain-id 137 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(string,string,address)" "Penalty Game" "PG" 0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372) \
    --etherscan-api-key $POLYGONSCAN_API_KEY \
    --optimizer-runs 200 \
    0x07d8Cb502429483485ae3eaC4Ac8DA3E038b8b80 \
    src/CommunityToken.sol:CommunityToken

    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0xEa4e3Af80a3fb7d8C6fCaC9632034ab41170Da68 \
    src/TokenPool.sol:TokenPool

    forge verify-contract \
    --chain-id 137 \
    --watch \
    --etherscan-api-key $POLYGONSCAN_API_KEY \
    --optimizer-runs 200 \
    0xEa4e3Af80a3fb7d8C6fCaC9632034ab41170Da68 \
    src/TokenPool.sol:TokenPool

    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0x2B6Bd7190eD74161C979623f9B5E6d02861Dda44 \
    src/TokenTransferRequest.sol:TokenTransferRequest

    forge verify-contract \
    --chain-id 137 \
    --watch \
    --etherscan-api-key $POLYGONSCAN_API_KEY \
    --optimizer-runs 200 \
    0x2B6Bd7190eD74161C979623f9B5E6d02861Dda44 \
    src/TokenTransferRequest.sol:TokenTransferRequest

    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address,address)" 0xEa4e3Af80a3fb7d8C6fCaC9632034ab41170Da68 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3) \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372 \
    src/CommunityRegistry.sol:CommunityRegistry

    forge verify-contract \
    --chain-id 137 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address,address)" 0xEa4e3Af80a3fb7d8C6fCaC9632034ab41170Da68 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3) \
    --etherscan-api-key $POLYGONSCAN_API_KEY \
    --optimizer-runs 200 \
    0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372 \
    src/CommunityRegistry.sol:CommunityRegistry

    forge verify-contract --verifier-url https://api.polygonscan.com/api/ 0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372 ./ $POLYGONSCAN_API_KEY
 */
contract DeployPenaltyGame is Script {

    function run() external returns (CommunityToken communityToken, TokenTransferRequest tokenTransferRequest, TokenPool tokenPool, CommunityRegistry communityRegistry, HelperConfig helperConfig) {
        helperConfig = new HelperConfig();
        (uint256 deployerKey, address admin, , , ) = helperConfig.config();
        
        vm.startBroadcast(deployerKey);
        tokenTransferRequest = new TokenTransferRequest();
        tokenPool = new TokenPool();
        communityRegistry = new CommunityRegistry(tokenPool, admin);
        tokenPool.transferOwnership(address(communityRegistry));
        vm.stopBroadcast();

        vm.startBroadcast(admin);
        communityToken = communityRegistry.deployCommunityContract("Penalty Game", "PG");
        vm.stopBroadcast();

        return (communityToken, tokenTransferRequest, tokenPool, communityRegistry, helperConfig);
    }
}
