// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Preservation, LibraryContract} from "../src/Level16.sol";
import {PreservationExploit} from "../src/Level16Exploit.sol";

contract Level16Test is Test {
    Preservation public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        LibraryContract lib1 = new LibraryContract();
        LibraryContract lib2 = new LibraryContract();
        target = new Preservation(address(lib1), address(lib2));
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertEq(target.owner(), attacker.addr);
    }

    function exploit(address _target) private {
        PreservationExploit e = new PreservationExploit();
        e.exploit(_target);
    }
}
