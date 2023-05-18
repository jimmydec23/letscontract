// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract Government {
    // index of the first creditor that hasn't been paid out
    uint32 public lastCreditorPayedOut;

    // unix timestamp of the last investment
    uint public lastTimeOfNewCredit;

    // jackpot that the last creditor stands to win
    uint public profitFromCrash;

    // a list of creditor address
    address[] public creditorAddresses;

    // a list of amounts owed to each creditor
    uint[] public creditorAmounts;

    // creator of the contract
    address public corruptElite;

    // a mapping of creditor address to their amount
    mapping(address => uint) buddies;

    // 12 hours in second
    uint constant TWELVE_HOURS = 432000;

    // every time a jackpot is paid out, a new round begins
    uint8 public round;

    /// @notice init variables
    constructor() payable {
        profitFromCrash = msg.value;
        corruptElite = msg.sender;
        lastTimeOfNewCredit = block.timestamp;
    }
}