// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

/// @notice contract rules:
/// 1. You lend the government money and the promise pay it back with 10% interest
/// 2. If the goverment does not receive new money for 12 hours, it break,
///    the lastest creditor receives the jackpot
/// 3. Your money used in the following way: 5% to jackpot (max 10,000 eth), 
///    5% to corrupt elite who runs the government, 90% to pay out old creditors.
///    when jackpot reach 10,000 eth, 95% to pay out old creditors.
/// 4. Creditors can share an affiliate link. 5% goes toward the linker, 5% to 
///    jackpt, 5% to corrupt elite, the rest to pay out old creditors.
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


    function lendGovernmentMoney(address buddy) public payable returns (bool) {
        uint amount = msg.value;
        
        // if for 12h no new creditor gives new credit, system break down
        if (lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp) {
            // return money back
            payable(msg.sender).transfer(amount);
            // last creditor get all the contract money
            payable(creditorAddresses[creditorAddresses.length-1])
                .transfer(profitFromCrash);
            // contract balance return to contract creator
            payable(corruptElite).transfer(address(this).balance);

            //reset contract
            lastCreditorPayedOut = 0;
            lastTimeOfNewCredit = block.timestamp;
            profitFromCrash = 0;
            creditorAddresses = new address[](0);
            creditorAmounts = new uint[](0);
            round += 1;
            return false;
        }else{
            // at lease 1 eth
            if (amount >= 10**18){
                // survice time add 12 hour
                lastTimeOfNewCredit = block.timestamp;
                // register the new creditor and his amount with 10% interest rate
                creditorAddresses.push(msg.sender);
                creditorAmounts.push(amount*110/100);
                // corrupt elite grab 5%
                payable(corruptElite).transfer(amount*5/100);
                // jackpot grab 5%
                if(profitFromCrash < 10000*10**18){
                    profitFromCrash += amount * 5/100;
                }
                // buddy in the goverment grab 5%
                if(buddies[buddy] >= amount) {
                    payable(buddy).transfer(amount * 5/100);
                }
                buddies[msg.sender] = amount * 110/100;
                // 90% will be used to pay out old creditors
                if (creditorAmounts[lastCreditorPayedOut] <= address(this).balance
                - profitFromCrash) {
                    payable(creditorAddresses[lastCreditorPayedOut])
                        .transfer(creditorAmounts[lastCreditorPayedOut]);
                    buddies[creditorAddresses[lastCreditorPayedOut]]
                        -= creditorAmounts[lastCreditorPayedOut];
                    lastCreditorPayedOut += 1;
                }
                return true;

            }else{
                // not enough credit
                payable(msg.sender).transfer(amount);
                return false;
            }
        }
    }

    fallback() external payable {
        lendGovernmentMoney(address(0));
    }

    receive() external payable{}

    /// @notice The government owes investors 
    /// whose order behide (include) lastCreditorPayedOut 
    function totalDept() public view returns (uint debt) {
        for (uint i = lastCreditorPayedOut; i < creditorAmounts.length; i++ ){
            debt += creditorAmounts[i];
        }
    }

    /// @notice investors whose order before lastCreditorPayedOut
    /// already get their mondy back
    function totalPayedOut() public view returns (uint payout) {
        for (uint i = 0; i < lastCreditorPayedOut; i++) {
            payout += creditorAmounts[i];
        }
    }
    
    /// @notice increase the jackpot
    function investInTheSystem() public payable {
        profitFromCrash += msg.value;
    }

    /// @notice transfer contract corrupt elite to next generation
    function inheritToNextGeneration(address nextGeneration) public {
        if (msg.sender == corruptElite) {
            corruptElite = nextGeneration;
        }
    }

    /// @notice return all creditor address
    function getCreditorAddresses() public view returns (address[] memory) {
        return creditorAddresses;
    }

    /// @notice return all creditor amounts
    function getCreditorAmounts() public view returns (uint[] memory) {
        return creditorAmounts;
    }
}