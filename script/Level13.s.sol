pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {GatekeeperOne} from "../src/Level13.sol";
import {GatekeeperOneExploit} from "../src/Level13Exploit.sol";

contract Level13Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        new GatekeeperOneExploit(_target);
    }

    function levelDone(address _target) private view returns (bool) {
        return GatekeeperOne(_target).entrant() != address(0);
    }
}
