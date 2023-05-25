// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract Powerball {
    struct Round {

        // ticket purchase deadline
        uint endTime;

        // a future block number to use for generating a random number
        uint drawBlock;

        // six winning numbers
        uint[6] winningNumbers;

        // a list of tickets, solidity array is special: uint[6][] means
        // [[x1,x2,x3,x4,x5,x6], [y1,y2,y3,y4,y5,y6], ...], 6 means the length
        // of subarray
        mapping (address => uint[6][]) tickets;
    }

    // ticket price
    uint public constant TICKET_PRICE = 2e15;

    // ball numer from 1 to 69
    uint public constant MAX_NUMBER = 69;

    // power ball number from 1 to 26
    uint public constant MAX_POWERBALL_NUMBER = 26;

    // 3 day a round
    uint public constant ROUND_LENGTH = 3 days;

    // rounds counter
    uint public round;

    // rounds mapping
    mapping (uint => Round) public rounds;

    constructor() {
        round = 1;
        rounds[round].endTime = block.timestamp + ROUND_LENGTH;        
    }

    /// @notice buy ticket or multiple tickets
    function buy(uint[6][] memory numbers) payable public {
        require(numbers.length * TICKET_PRICE == msg.value);
        // check if numbers are valid
        for (uint i = 0; i < numbers.length; i++){
            // ball number form 1 to 69
            for (uint j = 0; j < 5; j++){
                require(numbers[i][j] > 0);
                require(numbers[i][j] <= MAX_NUMBER);
            }
            // power ball number from 1 to 26
            require(numbers[i][5] > 0);
            require(numbers[i][5] < MAX_POWERBALL_NUMBER);
        }
        // update round info
        if (block.timestamp > rounds[round].endTime) {
            rounds[round].drawBlock = block.number + 5;
            round += 1;
            rounds[round].endTime = block.timestamp + ROUND_LENGTH;
        }
        // add tickets to round
        for (uint i=0; i < numbers.length; i++) {
            rounds[round].tickets[msg.sender].push(numbers[i]);
        }
    }

    /// @notice draw 6 balls
    function drawNumbers(uint _round) public {
        Round storage r = rounds[_round];
        uint drawBlock = r.drawBlock;
        // require round time match
        require(block.timestamp > r.endTime);
        // require block number match
        require(block.number >= drawBlock);
        // require current round not drawed
        require(r.winningNumbers[0] == 0);

        // generate winning balls
        for (uint i=0; i < 5; i++){
            bytes32 rand = keccak256(abi.encode(blockhash(drawBlock),i));
            uint numberDraw = uint(rand) % MAX_NUMBER + 1;
            rounds[_round].winningNumbers[i] = numberDraw;
        }

        // generate powerball
        bytes32 rand2 = keccak256(abi.encode(blockhash(drawBlock), 5));
        uint powerballDraw = uint(rand2) % MAX_POWERBALL_NUMBER + 1;
        rounds[_round].winningNumbers[5] = powerballDraw;
    }

    /// @notice player claim their rewards
    function claim(uint _round) public {
        Round storage r = rounds[_round];
        // require a ticket buyer
        require(r.tickets[msg.sender].length > 0);
        // require round has been drawed
        require(r.winningNumbers[0] != 0);

        uint[6][] storage myNumbers = r.tickets[msg.sender];
        uint[6] storage winningNumbers = r.winningNumbers;

        uint payout = 0;
        // player might buy multiple ticket
        for (uint i=0; i < myNumbers.length; i++){
            uint numberMatches = 0;
            // iter current ticket
            for(uint j=0; j < 5; j++){
                // iter winningNumbers
                for(uint k=0; k < 5; k++){
                    if(myNumbers[i][j] == winningNumbers[k]){
                        numberMatches++;
                    }
                }
            }
            bool powerballMatches = (myNumbers[i][5] == winningNumbers[5]);
            // match all and take all
            if(numberMatches == 5 && powerballMatches){
                payout = address(this).balance;
                break; // no need to calculate other tickets
            }else if(numberMatches == 5) {
                payout += 1000 ether;
            }else if(numberMatches == 4 && powerballMatches){
                payout += 50 ether;
            }else if(numberMatches == 4){
                payout += 1e17;
            }else if(numberMatches == 3 && powerballMatches){
                payout += 1e17;
            }else if(numberMatches == 3){
                payout += 7e15;
            }else if(numberMatches == 2 && powerballMatches){
                payout += 7e15;
            }else if(powerballMatches){
                payout += 4e15;
            }
        }
        if (payout > 0) {
            payable(msg.sender).transfer(payout);
        }
        delete rounds[_round].tickets[msg.sender];
    }

    /// @notice check user tickets
    function ticketsFor(uint _round, address user) 
        public view returns (uint[6][] memory ){
        return rounds[_round].tickets[user];
    }

    /// @notice chck winner numbers
    function winningNumbersFor(uint _round) public view returns(uint[6] memory) {
        return rounds[_round].winningNumbers;
    }
}