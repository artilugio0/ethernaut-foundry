pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

interface Level00 {
    function authenticate(string calldata password) external;

    function password() external returns (string memory);
}

contract Level00Script is Script {
    function setUp() public {}

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address contractAddress = vm.envAddress("CONTRACT");
        Level00 target = Level00(contractAddress);

        string memory password = target.password();

        vm.startBroadcast(pk);
        target.authenticate(password);
        vm.stopBroadcast();

        require(levelDone(contractAddress), "Solution failed");
    }

    function levelDone(address contractAddress) private view returns (bool) {
        uint256 varValue = uint256(vm.load(contractAddress, bytes32(uint256((3)))));

        return varValue == 1;
    }
}
