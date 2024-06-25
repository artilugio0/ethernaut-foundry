// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "openzeppelin-contracts-08/utils/Address.sol";

interface GoodSamaritan {
    function wallet() external returns (address);
    function coin() external returns (address);
    function requestDonation() external returns (bool);
}

interface Coin {
    function transfer(address dest_, uint256 amount_) external;
    function balances(address) external returns (uint256);
}

interface Wallet {
    function owner() external returns (address);
    function coin() external returns (address);
}

interface INotifyable {
    function notify(uint256 amount) external;
}
