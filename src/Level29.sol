// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";

contract Switch {
    bool public switchOn; // switch is off
    bytes4 public offSelector = bytes4(keccak256("turnSwitchOff()"));

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    modifier onlyOff() {
        // we use a complex data type to put in memory
        bytes32[1] memory selector;
        // check that the calldata at position 68 (location of _data)
        assembly {
            calldatacopy(selector, 68, 4) // grab function selector from calldata
        }

        require(selector[0] == offSelector, "Can only call the turnOffSwitch function");
        _;
    }

    function flipSwitch(bytes memory _data) public {
        console.log("CALLDATA[0] %x", uint32(bytes4(msg.data)));
        console.log("CALLDATA[1] %x", uint256(bytes32(msg.data[4:])));
        console.log("CALLDATA[2] %x", uint256(bytes32(msg.data[32+4:])));
        console.log("CALLDATA[3] %x", uint256(bytes32(msg.data[32*2+4:])));
        console.log("CALLDATA[4] %x", uint256(bytes32(msg.data[32*3+4:])));
        console.log("SELECTOR %x", uint256((keccak256("turnSwitchOff()"))));

        (bool success,) = address(this).call(_data);
        require(success, "call failed :(");
    }

    function turnSwitchOn() public onlyThis {
        switchOn = true;
    }

    function turnSwitchOff() public onlyThis {
        switchOn = false;
    }
}
