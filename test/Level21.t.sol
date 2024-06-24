// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Shop} from "../src/Level21.sol";
import {ShopExploit} from "../src/Level21Exploit.sol";

contract Level21Test is Test {
    Shop public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        target = new Shop();
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertLt(target.price(), 100);
    }

    function exploit(address _target) private {
        ShopExploit e = new ShopExploit();
        e.exploit(_target);
    }
}
