// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract RecurringLottery {
    struct Round {
        // A round ends when block number endBlock is mined
        uint endBlock;
        // Used to generate a random seed
        uint drawBlock;
        // entry list
        Entry[] entries;
        // Track the number of tickets sold in each round.
        uint totalQuantity;
        // Determined by selecting a random entry from entryes
        address winner;
    }

    struct Entry {
        // buyer address
        address buyer;
        // quntity of tickets purchased
        uint quantity;
    }

    // ticket price
    uint constant public TICKET_PRICE = 1e15;

    // rand number to Round struct
    mapping (uint => Round ) public rounds;

    // round number
    uint public round;

    // the duration of a single round in blocks
    uint public duration;

    // user to balance
    mapping(address => uint) public balances;

    /// @notice duration is in blocks.
    constructor(uint _duration) {
        duration = _duration;
        round = 1;
        rounds[round].endBlock = block.number + duration;
        rounds[round].drawBlock = block.number + duration + 5;
    }

    /// @notice you can buy one or more ticket
    function buy() payable public {
        require(msg.value % TICKET_PRICE == 0);
        
        // update round
        if (block.number > rounds[round].endBlock) {
            round += 1;
            rounds[round].endBlock = block.number + duration;
            rounds[round].drawBlock = block.number + duration + 5;
        }

        uint quantity = msg.value / TICKET_PRICE;
        Entry memory e = Entry(msg.sender, quantity);
        rounds[round].entries.push(e);
        rounds[round].totalQuantity += quantity;
    }

    function drawWinner(uint roundNumber) public {
        Round storage drawing = rounds[roundNumber];
        // require round not drawed
        require(drawing.winner == address(0));
        // block limit
        require(block.number > drawing.drawBlock);
        // reqire not empty entries
        require(drawing.entries.length > 0);

        // generate a rand
        bytes32 rand = keccak256(
            abi.encode(blockhash(drawing.drawBlock))
        );
        uint counter = uint(rand) % drawing.totalQuantity;

        // check which dration the counter is in
        for(uint i = 0; i < drawing.entries.length; i++){
            uint quantity = drawing.entries[i].quantity;
            if(quantity > counter){
                drawing.winner = drawing.entries[i].buyer;
                break;
            }else{
                counter -= quantity;
            }
        }
        // add round's balance to winner's
        balances[drawing.winner] += TICKET_PRICE * drawing.totalQuantity;
    }

    /// @notice the winner withdraw his balance
    function withdraw() public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    
    /// @notice delete a round to clean up old data.
    function deleteRound(uint _round) public {
        // a round exist too long
        require(block.number > rounds[_round].drawBlock + 100);
        // a round has a winner
        require(rounds[_round].winner != address(0));
        delete rounds[_round];
    }
}