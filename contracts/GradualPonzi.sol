// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract GradualPonzi {
    address[] public investors;
    mapping (address => uint) public balancees;
    uint public constant MINIMUM_INVESTMENT = 1e15;

    /// @notice contract owner has a share
    constructor() {
        investors.push(msg.sender);
    }

    /// @notice new investor put money in, old investors share it
    function invest() public payable {
        require(msg.value >= MINIMUM_INVESTMENT, "require minimum investment");
        uint eachInvestorGets = msg.value / investors.length;
        for (uint i=0; i < investors.length; i++) {
            balancees[investors[i]] += eachInvestorGets;
        }
        investors.push(msg.sender);
    }

    /// @notice investor get back his earning
    function withdraw() public {
        uint payout = balancees[msg.sender];
        balancees[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }
}