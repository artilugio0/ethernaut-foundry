pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Shop} from "../src/Level21.sol";
import {ShopExploit} from "../src/Level21Exploit.sol";

contract Level21Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        ShopExploit e = new ShopExploit();
        e.exploit(_target);
    }

    function levelDone(address _target) private returns (bool) {
        return Shop(_target).price() < 100;
    }
}
