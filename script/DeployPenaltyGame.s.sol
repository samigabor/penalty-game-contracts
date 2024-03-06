// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {CommunityToken} from "../src/CommunityToken.sol";
import {TokenTransferRequest} from "../src/TokenTransferRequest.sol";
import {CommunityRegistry} from "../src/CommunityRegistry.sol";
import {TokenPool} from "../src/TokenPool.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

address constant COMMUNITY_TOKEN_ADDRESS = 0xbCbA2AeEAC9FD0506F8E2B6D951C1E870CC447c8;
address constant TOKEN_POOL_ADDRESS = 0x3e488DC02DD6E8B6e6Ff3D2Acf6506Bf3a58bB02;
address constant COMMUNITY_REGISTRY_ADDRESS = 0xDC98a83A93895999d9Ce6336932Ef99fE6a87038;

// deployed but not used in this script
// address constant TRANSFER_REQUEST_TOKEN_ADDRESS = 0xE2BaDfc491fe719ae905d39FfC36DA2D20b495d6;
// address constant HELPER_CONFIG_ADDRESS = 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141;

/**
 * @dev Deploy to anvil
    forge script script/DeployPenaltyGame.s.sol \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast

 * @dev Script to deploy all contract and transfer ownership to CommunityRegistry:
    forge script script/DeployPenaltyGame.s.sol \
    --rpc-url $RPC_URL_SEPOLIA \
    --optimizer-runs 200 \
    --broadcast \
    --private-key=$PRIVATE_KEY

 * @dev Manual deployment example:
    forge create \
    --rpc-url $RPC_URL_SEPOLIA \
    --optimizer-runs 200 \
    --constructor-args "Penalty Game" "PG" \
    --private-key $PRIVATE_KEY \
    src/CommunityToken.sol:CommunityToken

 * @dev Manual Verification required for each contract:
    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(string,string)" "Penalty Game" "PG") \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0xbCbA2AeEAC9FD0506F8E2B6D951C1E870CC447c8 \
    src/CommunityToken.sol:CommunityToken

    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0x3e488DC02DD6E8B6e6Ff3D2Acf6506Bf3a58bB02 \
    src/TokenPool.sol:TokenPool

    forge verify-contract \
    --chain-id 11155111 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address,address)" 0x3e488DC02DD6E8B6e6Ff3D2Acf6506Bf3a58bB02 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3) \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --optimizer-runs 200 \
    0xDC98a83A93895999d9Ce6336932Ef99fE6a87038 \
    src/CommunityRegistry.sol:CommunityRegistry
 */
contract DeployPenaltyGame is Script {

    function run() external returns (CommunityToken communityToken, TokenTransferRequest tokenTransferRequest, TokenPool tokenPool, CommunityRegistry communityRegistry, HelperConfig helperConfig) {
        helperConfig = new HelperConfig();
        (uint256 deployerKey, address admin, , , ) = helperConfig.config();
        
        vm.startBroadcast(deployerKey);
        communityToken = new CommunityToken("Penalty Game", "PG");
        tokenTransferRequest = new TokenTransferRequest();
        tokenPool = new TokenPool();
        communityRegistry = new CommunityRegistry(tokenPool, admin);

        communityToken.transferOwnership(address(communityRegistry));
        tokenPool.transferOwnership(address(communityRegistry));

        vm.stopBroadcast();

        return (communityToken, tokenTransferRequest, tokenPool, communityRegistry, helperConfig);
    }
}
