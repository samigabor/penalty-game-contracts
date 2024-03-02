// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {console} from "forge-std/Test.sol";

contract HelperConfig is Script {
    struct Config {
        uint256 deployKey;
    }
    uint256 public constant ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    Config public config;

    constructor() {
        if (block.chainid == 11155111) {
            config = getSepoliaConfig();
            console.log("Sepolia config: %s", config.deployKey);
        } else {
            config = getOrCreateAnvilConfig();
            console.log("Anvil config: %s", config.deployKey);
        }
    }

    function getSepoliaConfig() public view returns (Config memory) {
        return Config({
            deployKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getOrCreateAnvilConfig() public pure returns (Config memory) {
        return Config({
            deployKey: ANVIL_KEY
        });
    }
}