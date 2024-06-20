// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Telephone} from "../src/Level04.sol";
import {TelephoneExploit} from "../src/Level04Exploit.sol";

contract Level04Test is Test {
    Telephone public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        target = new Telephone();
    }

    function test_getContractOwnership() public {
        // use prank to emulate tx.origin and msg.sender
        vm.startPrank(attacker.addr, attacker.addr);
        exploit();
        vm.stopPrank();

        assertEq(target.owner(), attacker.addr);
    }

    function exploit() private {
        new TelephoneExploit(address(target), attacker.addr);
    }
}
