// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract RNGLottery {
    
    // the ticket price
    uint constant public TICKET_PRICE = 1e16;

    // tickets buyer addresses
    address[] public tickets;

    // lottery winner
    address public winner;

    // the random seed to generate winner.
    bytes32 public seed;

    // every player submits a commitment with their ticket purchase
    mapping (address => bytes32) public commitments;

    // ticket cann't be purchased after this block number
    uint public ticketDeadline;

    // reveal must occur after ticketDeadline and before the reveal deadline
    uint public revealDeadline;

    // draw after this block
    uint public drawBlock;

    constructor(uint duration, uint revealDuration) {
        ticketDeadline = block.number + duration;
        revealDeadline = ticketDeadline + revealDuration;
        drawBlock = revealDeadline + 5;
    }

    /// @notice generate commitment by user and user's random number
    function createCommitment(address user, uint N) public pure 
        returns (bytes32 commitment) {
        return keccak256(abi.encodePacked(user, N));
    }

    /// @notice player buy a ticket and sumbit a commitment
    function buy(bytes32 commitment) payable public {
        console.log("reveal", block.number, ticketDeadline, revealDeadline);
        require(msg.value == TICKET_PRICE);
        require(block.number < ticketDeadline);
        commitments[msg.sender] = commitment;
    }

    /// @notice player must reveal it's commitment to join the lottery.
    /// seed changed every time a player reveal his rand
    function reveal(uint N) public {
        console.log("reveal", block.number, ticketDeadline, revealDeadline);
        require(block.number >= ticketDeadline);
        require(block.number <= revealDeadline);
        bytes32 hash = createCommitment(msg.sender, N);
        require(hash == commitments[msg.sender]);
        seed = keccak256(abi.encodePacked(seed, N));
        tickets.push(msg.sender);
    }

    /// @notice draw the lottery winner
    function drawWinner() public {
        require(block.number > drawBlock);
        require(winner == address(0));
        uint randIndex = uint(seed) % tickets.length;
        winner = tickets[randIndex];
    }

    /// @notice winner withdrwa reward
    function withdraw() public {
        require(msg.sender == winner);
        payable(msg.sender).transfer(address(this).balance);
    }
}