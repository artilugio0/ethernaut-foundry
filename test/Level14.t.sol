// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {GatekeeperTwo} from "../src/Level14.sol";
import {GatekeeperTwoExploit} from "../src/Level14Exploit.sol";

contract Level14Test is Test {
    GatekeeperTwo public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        target = new GatekeeperTwo();
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertNotEq(target.entrant(), address(0));
    }

    function exploit(address _target) private {
        new GatekeeperTwoExploit(_target);
    }
}
