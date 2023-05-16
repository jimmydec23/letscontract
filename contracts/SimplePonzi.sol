// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract SimplePonzi {
    address public currentInvestor;
    uint public currentInvestment = 0;

    fallback() payable external {
        // new investments must be 10% greater then current 
        uint minimumInvestment = currentInvestment * 11/10;
        require(msg.value > minimumInvestment, "require minimum investment");
        
        // document new investor
        address previousInvestor = currentInvestor;
        currentInvestor = msg.sender;
        currentInvestment = msg.value;

        // payout previous investor
        // use send instead of transfer
        payable(previousInvestor).send(msg.value);
    }
    
    receive() external payable {}
}