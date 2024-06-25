pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {Solution} from "../src/Level26Solution.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import {CryptoVault, LegacyToken, DoubleEntryPoint, Forta, DelegateERC20} from "../src/Level26.sol";

contract Level26Script is Script {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(vm.envUint("PRIVATE_KEY"));

        address payable contractAddress = payable(vm.envAddress("CONTRACT"));

        vm.startBroadcast(wallet.privateKey);
        solution(contractAddress);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function solution(address _target) private {
        Forta forta = DoubleEntryPoint(address(CryptoVault(_target).underlying())).forta();
        Solution bot = new Solution(address(forta), _target);
        forta.setDetectionBot(address(bot));
    }

    function levelDone(address _target) private returns (bool) {
        IERC20 underlying = CryptoVault(_target).underlying();
        address legacy = DoubleEntryPoint(address(underlying)).delegatedFrom();

        try CryptoVault(_target).sweepToken(IERC20(legacy)) {
            return false;
        } catch {}

        return true;
    }
}

interface Engine {
    function horsePower() external returns (uint256);
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}
