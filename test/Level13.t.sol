// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {GatekeeperOne} from "../src/Level13.sol";
import {GatekeeperOneExploit} from "../src/Level13Exploit.sol";

contract Level13Test is Test {
    GatekeeperOne public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        target = new GatekeeperOne();
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertNotEq(target.entrant(), address(0));
    }

    function exploit(address _target) private {
        new GatekeeperOneExploit(_target);
    }
}
