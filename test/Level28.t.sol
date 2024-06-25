// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {GatekeeperThree, SimpleTrick} from "../src/Level28.sol";
import {GatekeeperThreeExploit} from "../src/Level28Exploit.sol";

contract Level28Test is Test {
    GatekeeperThree public target;
    address public token1;
    address public token2;

    VmSafe.Wallet attacker;
    VmSafe.Wallet player;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        vm.deal(attacker.addr, 1 ether);
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        target = new GatekeeperThree();
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertEq(target.entrant(), attacker.addr);
    }

    function exploit(address _target) private {
        GatekeeperThreeExploit e = new GatekeeperThreeExploit();
        e.exploit{value: 0.0011 ether}(payable(_target));
    }
}
