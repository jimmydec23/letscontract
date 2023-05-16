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
        // send: return ture of false
        // transfer: throw exception when execution failed
        // both have a gas stipend of 2300 to againest reentrancy
        // after Istanbul update(cost increase, 2300 is not engough), 
        // call is recommented.
        //payable(previousInvestor).transfer(msg.value);
        (bool success,) = previousInvestor.call{value: msg.value}("");
        require(success, "Transfer failed.");
    }
    
    receive() external payable {}
}