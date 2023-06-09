// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

/// @notice simulate sasino roulette on blockchain
contract CasinoRoulette {
    /// @notice a winning color bey pays out 2x, 
    /// a winning number bet pays out 35x
    enum BetType {Color, Number}

    struct Bet {
        // bet user
        address user;
        // how much you put on the bet
        uint amount;
        // set the bet type, color or number
        BetType betType;
        // the block variable
        uint block;
        // when betType = Color, choice must be 0 for black, 1 for red
        // when betType = Number, choice range from -1 to 36
        int choice;
    }
    // the number of pockets in a roulette wheel, 
    // range from -1 - 36, total 38 pockets
    uint public constant NUM_POCKETS = 38;
    // red number pockets
    uint8[18] public RED_NUMBERS = [
        1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36
    ];
    // black number pockets
    uint8[18] public BLACK_NUMBERS = [
        2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35
    ];
    // maps wheel numbers to colors, 0 for black, 1 for red
    mapping (int=> int) public colors;
    // address owner
    address public owner;
    // bet id generated by the increamenting counter
    uint public counter = 0;
    // bets mapping
    mapping(uint => Bet) public bets;

    // trigger at bet placed
    event BetPlaced(
        address user, uint amount, BetType betType, uint block, int choice
    );
    // trigger at spin
    event Spin(uint id, int landed);

    /// @notice mark owner
    constructor() payable {
        owner = msg.sender;
        for(uint i=0; i < 18; i++){
            // multiple conversions: uint8 => uint256 => int256
            int n = int(uint(RED_NUMBERS[i]));
            colors[n] = 1;
        }
    }
    
    /// @notice wager
    function wager (BetType betType, int choice) public payable {
        // input check
        require(msg.value > 0);
        if(betType == BetType.Color) {
            require(choice == 0 || choice == 1);
        }else{
            require(choice >= -1 && choice <= 36);
        }
        // add a bet
        counter++;
        bets[counter] = Bet(
            msg.sender,msg.value,betType,block.number+3,choice
        );
        emit BetPlaced(
            msg.sender,msg.value,betType,block.number+3,choice
        );
    }

    /// @notice spin the wheel
    /// if the contract's balance is not enough, pay out may fail!
    function spin(uint id) public {
        Bet storage bet = bets[id];
        // block number check
        require(msg.sender == bet.user);
        require(block.number >= bet.block);
        require(block.number <= bet.block + 255);
        // random a number
        bytes32 random = keccak256(abi.encode(blockhash(bet.block), id));
        int landed = int(uint(random)%NUM_POCKETS) - 1;

        if(bet.betType == BetType.Color){
            // for a color bet
            if(landed > 0 && colors[landed] == bet.choice){
                // 2x pay out
                payable(msg.sender).transfer(bet.amount*2);
            }
        }else if(bet.betType == BetType.Number){
            // for a number bet
            if(landed == bet.choice){
                payable(msg.sender).transfer(bet.amount*35);
            }
        }
        delete bets[id];
        emit Spin(id, landed);
    }

    /// @notice fund the roulette
    function fund() public payable{}
    
    /// @notice kill the contract
    function kill() public {
        require(msg.sender == owner);
        selfdestruct(payable(owner));
    }
}