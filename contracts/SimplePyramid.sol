// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract SimplePyramid {
    // set minimum investment to 0.001 eth
    uint public constant MINIMUM_INVESTMENT = 1e15;
    uint public numInvestors = 0;
    uint public depth = 0;
    uint public depthIncreasePosition = 0;
    address[] public investors;
    mapping(address => uint) public balances;

    /// @notice init parametors, contract address holds balance at first
    constructor() payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        investors.push(msg.sender);
        numInvestors = 1;
        depth = 1;
        depthIncreasePosition = 3;
        balances[address(this)] = msg.value;
    }

    /// @notice investor tree like this:
    /// I
    /// I I
    /// I I I I
    /// relationship between depth and chairs of depth is:
    /// chairs of depth = 2 ** depth
    /// when depth(L) is full, all investors in depth(L-1) will get back
    /// their investment and the remain money will be share to every one. 
    function invest() payable public {
        require(msg.value >= MINIMUM_INVESTMENT, "require minimum investment");
        // update investors document
        balances[address(this)] += msg.value;
        numInvestors += 1;
        investors.push(msg.sender);
        // old investor share the money
        if (numInvestors == depthIncreasePosition) {
            // pay out previous layer
            uint endIndex = numInvestors - 2**depth;
            uint startIndex = endIndex - 2**(depth-1);
            for(uint i = startIndex; i < endIndex; i++){
                balances[investors[i]] += MINIMUM_INVESTMENT;
            }
            // spread remaining ether among all participants
            uint paid = MINIMUM_INVESTMENT * 2 ** (depth - 1);
            uint eachInvestorGets = (balances[address(this)] - paid) / numInvestors;
            for(uint i=0; i < numInvestors; i++){
                balances[investors[i]] += eachInvestorGets;
            }
            balances[msg.sender] = 0;
            depth += 1;
            depthIncreasePosition += 2 ** depth;
        }
    }
    
    /// @notice withdraw earning
    function withdraw() public {
        uint payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }

    /// @notice check token owner balance
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}