// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Force} from "../src/Level07.sol";
import {ForceExploit} from "../src/Level07Exploit.sol";

contract Level07Test is Test {
    Force public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        target = new Force();
    }

    function test_getContractOwnership() public {
        vm.deal(attacker.addr, 1 wei);
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertGt(address(target).balance, 0);
    }

    function test_getContractOwnershipWithSelfdestructOutsideOfConstructor() public {
        vm.deal(attacker.addr, 1 wei);
        vm.startPrank(attacker.addr, attacker.addr);
        exploitOutsideConstructor(address(target));
        vm.stopPrank();

        assertGt(address(target).balance, 0);
    }

    function exploit(address _target) private {
        new ForceExploit{value: 1 wei}(payable(_target));
    }

    function exploitOutsideConstructor(address _target) private {
        ForceExploit e = new ForceExploit(payable(0));
        e.exploit{value: 1 wei}(payable(_target));
    }
}
