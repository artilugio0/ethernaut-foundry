// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Denial} from "../src/Level20.sol";
import {DenialExploit} from "../src/Level20Exploit.sol";

contract Level20 is Test {
    Denial public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        target = new Denial();
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        vm.expectRevert();
        target.withdraw{gas:1000000}();
    }

    function exploit(address _target) private {
        new DenialExploit(_target);
    }
}
