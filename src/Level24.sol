pragma solidity ^0.8.14;

interface PuzzleWallet {
    function addToWhitelist(address) external;
    function admin() external view returns (address);
    function owner() external view returns (address);
    function pendingAdmin() external view returns (address);
    function proposeNewAdmin(address) external;
    function setMaxBalance(uint256) external;
    function multicall(bytes[] calldata) external payable;
}
