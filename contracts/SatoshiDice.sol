// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import "hardhat/console.sol";

/// @notice You wager, you roll, you win or lose.
contract SatoshiDice {
    struct Bet {
        // bet user address
        address user;
        // bet block
        uint block;
        // win while randoms a number below the cap
        uint cap;
        // how mouch user put on the bet
        uint amount;
    }

    // numerator of fee, 1%
    uint public constant FEE_NUMERATOR = 1;
    // denominator of fee
    uint public constant FEE_DENOMINATOR = 100;
    // maximum bet number
    uint public constant MAXIMUM_CAP = 100000;
    // maximum bet value
    uint public constant MAXIMUM_BET_SIZE = 1e18;
    // contract owner
    address owner;
    // an increamenting counter used to assign unique id
    uint public counter = 0;
    // a mapping of bet id to bets
    mapping (uint => Bet) public bets;

    // trigger when a wager is placed
    event BetPlaced(uint id, address user, uint cap, uint amount);
    // trigger when a roll was happened
    event Roll(uint id, uint rolled);

    /// @notice mark the owner
    constructor() {
        owner = msg.sender;
    }

    /// @param cap if the random number is smaller than cap, you win
    function wager(uint cap) public payable {
        require(cap < MAXIMUM_CAP);
        require(msg.value <= MAXIMUM_BET_SIZE);
        counter++;
        bets[counter] = Bet(
            msg.sender, block.number+3, cap, msg.value
        );
        emit BetPlaced(counter, msg.sender, cap, msg.value);
    }

    /// @notice player roll on his own bet.
    /// reward is bet value * (max cap / your cap), so the smaller your cap,
    /// the lager the reward, and of course the smaller chance.
    function roll(uint id) public {
        Bet storage bet = bets[id];
        console.log("roll", id, msg.sender, bet.user);
        require(msg.sender == bet.user);
        require(block.number > bet.block);
        require(block.number <= bet.block + 255);

        bytes32 random = keccak256(abi.encode(blockhash(bet.block), id));
        uint rolled = uint(random) % MAXIMUM_CAP;
        if (rolled < bet.cap){
            uint payout = bet.amount * MAXIMUM_CAP / bet.cap;
            uint fee = payout * FEE_NUMERATOR / FEE_DENOMINATOR;
            payout -= fee;
            payable(msg.sender).transfer(payout);
        }
        emit Roll(id, rolled);
        delete bets[id];
    }

    /// @notice contract can be funded by this function
    function fund() payable public {}

    /// @notice destroy contract
    function kill() public {
        require(msg.sender == owner);
        selfdestruct(payable(owner));
    }
}