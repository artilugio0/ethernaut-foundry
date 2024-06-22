// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Elevator} from "../src/Level11.sol";
import {ElevatorExploit} from "../src/Level11Exploit.sol";

contract Level11Test is Test {
    Elevator public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        target = new Elevator();
    }

    function test_getContractOwnership() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertTrue(target.top());
    }

    function exploit(address _target) private {
        ElevatorExploit e = new ElevatorExploit();
        e.exploit(_target);
    }
}
