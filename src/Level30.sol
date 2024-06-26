// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";

interface HigherOrder {
    function commander() external returns (address);
    function registerTreasury(uint8) external;
    function claimLeadership() external;
}
