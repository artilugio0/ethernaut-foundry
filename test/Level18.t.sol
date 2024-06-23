// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {MagicNum} from "../src/Level18.sol";

contract Level18Test is Test {
    MagicNum public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        target = new MagicNum();
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        address solver = target.solver();
        (bool ok, bytes memory data) = solver.call(abi.encodeWithSignature("whatIsTheMeaningOfLife()(uint256)"));
        assertTrue(ok);

        uint256 result = uint256(bytes32(data));
        assertEq(result, 42);
    }

    function exploit(address _token) private {
        address addr;
        uint256 ptr;

        assembly {
            ptr := mload(0x40)
            mstore(ptr, 0x600a600c600039600a6000f3602a60005260206000f300000000000000000000)
            addr := create(0, ptr, 22)
        }

        target.setSolver(addr);
    }
}
