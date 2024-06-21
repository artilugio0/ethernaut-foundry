// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {King} from "../src/Level09.sol";
import {KingExploit} from "../src/Level09Exploit.sol";

contract Level09Test is Test {
    King public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        vm.deal(address(this), 10 ether);

        attacker = vm.createWallet("attacker");
        target = new King();
    }

    function test_exploit() public {
        vm.deal(attacker.addr, 2 ether);

        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        (bool ok,) = payable(target).call{value: address(target).balance}("");

        assertNotEq(target._king(), address(this));
        assertFalse(ok);
    }

    function exploit(address _target) private {
        new KingExploit{value: _target.balance}(payable(_target));
    }

    receive() external payable {}
}
