pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {MagicNum} from "../src/Level18.sol";

contract Level18Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        address addr;
        uint256 ptr;

        assembly {
            ptr := mload(0x40)
            mstore(ptr, 0x600a600c600039600a6000f3602a60005260206000f300000000000000000000)
            addr := create(0, ptr, 22)
        }

        MagicNum(_target).setSolver(addr);
    }

    function levelDone(address _target) private returns (bool) {
        address solver = MagicNum(_target).solver();
        (bool ok, bytes memory data) = solver.call(abi.encodeWithSignature("whatIsTheMeaningOfLife()(uint256)"));
        if (!ok) {
            return false;
        }

        uint256 result = uint256(bytes32(data));
        return result == 42;
    }
}
