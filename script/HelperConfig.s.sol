// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {console} from "forge-std/Test.sol";

contract HelperConfig is Script {
    struct Config {
        uint256 deployKey;
        address admin;
        address from;
        address to;
        address approver;
    }
    uint256 public constant ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    Config public config;

    constructor() {
        if (block.chainid == 137) {
            config = getPolygonConfig();
            console.log("Polygon config: %s", config.deployKey);
        } else if (block.chainid == 80001) {
            config = getMumbaiConfig();
            console.log("Mumbai config: %s", config.deployKey);
        } else if (block.chainid == 11155111) {
            config = getSepoliaConfig();
            console.log("Sepolia config: %s", config.deployKey);
        } else {
            config = getOrCreateAnvilConfig();
            console.log("Anvil config: %s", config.deployKey);
        }
    }

    function getPolygonConfig() public view returns (Config memory) {
        return Config({
            deployKey: vm.envUint("PRIVATE_KEY"),
            admin: 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3,
            from: 0x90F010Dd9408575985da1C14dBD3920BB0FFa7b6,
            to: 0x7965f643967aB3cDe072cb45dc9AFAA08d68ABdf,
            approver: 0x06E91E93f0ae2B12AD00C7AC430D167767Eb1085
        });
    }

    function getMumbaiConfig() public view returns (Config memory) {
        return Config({
            deployKey: vm.envUint("PRIVATE_KEY"),
            admin: 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3,
            from: 0x90F010Dd9408575985da1C14dBD3920BB0FFa7b6,
            to: 0x7965f643967aB3cDe072cb45dc9AFAA08d68ABdf,
            approver: 0x06E91E93f0ae2B12AD00C7AC430D167767Eb1085
        });
    }

    function getSepoliaConfig() public view returns (Config memory) {
        return Config({
            deployKey: vm.envUint("PRIVATE_KEY"),
            admin: 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3,
            from: 0x90F010Dd9408575985da1C14dBD3920BB0FFa7b6,
            to: 0x7965f643967aB3cDe072cb45dc9AFAA08d68ABdf,
            approver: 0x06E91E93f0ae2B12AD00C7AC430D167767Eb1085
        });
    }

    function getOrCreateAnvilConfig() public returns (Config memory) {
        return Config({
            deployKey: ANVIL_KEY,
            admin: makeAddr("admin"),
            from: makeAddr("member1"),
            to: makeAddr("member2"),
            approver: makeAddr("member3")
        });
    }
}