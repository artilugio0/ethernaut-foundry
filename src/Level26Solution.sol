pragma solidity ^0.8.14;

import {IForta} from "./Level26.sol";

contract Solution {
    address private owner;
    address private forta;
    address private vault;


    constructor(address _forta, address _vault) {
        owner = msg.sender;
        forta = _forta;
        vault = _vault;
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        require(user == owner, "NOT_OWNER");
        address origSender = address(bytes20(msgData[4+32+32+12:]));
        if(origSender == vault) {
            IForta(forta).raiseAlert(owner);
        }
    }
}
