// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract SimpleLottery {
    // The price of a lottery ticket, 0.01 ether.
    uint public constant TICKET_PRICE = 1e16;
    // A list of addresses that have bought tickets.
    address[] public tickets;
    // The winner of the lottery
    address public winner;
    // A unix timestamp, tickets can be purchased up until this time.
    uint public ticketingCloses;

    /// @param duration how long the ticket's sellable time
    constructor(uint duration) {
        ticketingCloses = block.timestamp + duration;
    }

    /// @notice player pay TICKET_PRICE to purchase a ticket.
    function buy() public payable {
        require(msg.value == TICKET_PRICE);
        require(block.timestamp < ticketingCloses);
        tickets.push(msg.sender);
    }
    
    /// @notice genrate the rand by the last block number
    /// 5 minutes limit so the block number cann't be guessed
    function drawWinner() public {
        require(block.timestamp > ticketingCloses + 5 minutes);
        require(winner == address(0));
        bytes32 rand = keccak256(
            abi.encodePacked(blockhash(block.number-1))
        );
        winner = tickets[uint(rand) % tickets.length];
    }

    /// @notice the winner withdraw all the contract balance.
    function withdraw() public {
        require(msg.sender == winner);
        payable(msg.sender).transfer(address(this).balance);
    }

    /// @notice fallback funtion is to buy a ticket
    fallback() payable external {
        buy();
    }

    receive() payable external {}
}