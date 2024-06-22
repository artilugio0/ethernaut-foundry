pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {GatekeeperTwo} from "../src/Level14.sol";
import {GatekeeperTwoExploit} from "../src/Level14Exploit.sol";

contract Level14Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        new GatekeeperTwoExploit(_target);
    }

    function levelDone(address _target) private view returns (bool) {
        return GatekeeperTwo(_target).entrant() != address(0);
    }
}
