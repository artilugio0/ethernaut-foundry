// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {NaughtCoin} from "../src/Level15.sol";
import {NaughtCoinExploit} from "../src/Level15Exploit.sol";

contract Level15Test is Test {
    NaughtCoin public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        target = new NaughtCoin(attacker.addr);
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertEq(target.balanceOf(attacker.addr), 0);
    }

    function exploit(address _target) private {
        NaughtCoinExploit e = new NaughtCoinExploit();
        NaughtCoin(_target).approve(address(e), NaughtCoin(_target).balanceOf(attacker.addr));
        e.exploit(_target);
    }
}
