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
        if (block.chainid == 31337) {
            config = Config({
                deployKey: ANVIL_KEY,
                admin: makeAddr("admin"),
                from: makeAddr("user1"),
                to: makeAddr("user2"),
                approver: makeAddr("user3")
            });
        } else {
            config = Config({
                deployKey: vm.envUint("PRIVATE_KEY"),
                admin: address(uint160(vm.envUint("ADMIN"))),
                from: address(uint160(vm.envUint("USER1"))),
                to: address(uint160(vm.envUint("USER2"))),
                approver: address(uint160(vm.envUint("USER3")))
            });
        }
    }
}
