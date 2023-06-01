// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

/// @notice Bet on your prediction
/// Total shares is fixed. Trading price is below 100 wei. When the market
/// is resolved to Yes, every share worths 100 wei, so players want to purchase
/// and push the price high. When the market is resolveed to No, every share
/// worth 0 wei, so the push the price low.
contract PredictionMarket {
    // order typer: buy or sell
    enum OrderType {Buy, Sell}

    // represent the current resolution of the market:
    // open: market is trading, has not been resolved
    // yes or no: market has been resolved, yes or no
    enum Result{Open, Yes, No}

    // represent an order
    struct Order {
        address user;
        OrderType orderType;
        uint amount;
        uint price;
    }

    // transation fee charge buy market creater, 
    // solidity doesn't support decimals, so use two variables,
    // 1 / 500, ort 0.2%
    uint public constant TX_FEE_NUMERATOR = 1;
    uint public constant TX_FEE_DENOMINATOR = 500;

    // contract creater, marker owner
    address public owner;
    
    // the current state or the contract
    Result public result;

    // an uinx timestamp, end of market trading
    uint public deadline;

    // an incrementing order id 
    uint public counter;

    // the value of collateral held in the contract
    uint public collateral;

    // mapping of order id to order
    mapping (uint => Order) public orders;

    // mapping of user address to his shares
    mapping (address => uint) public shares;

    // mapping of user address to his internal balances
    mapping (address => uint) public balances;

    // logged when an order is added to the order book
    event OrderPlaced(uint orderId, address user, OrderType orderType,
        uint amount, uint price);

    // logged when an order is matched and a trade is executed
    event TradeMatched(uint orderId, address user, uint amount);

    // logged when an order is canceled
    event OrderCanceled(uint orderId);

    // logged when a user makes a withdraw
    event Payout(address user, uint amount);

    /// @notice 1 share = 100 wei
    /// @param duration trade duration in seconds
    constructor(uint duration) payable {
        require(msg.value > 0);
        owner = msg.sender;
        deadline = block.timestamp + duration;
        shares[msg.sender] = msg.value / 100;
        collateral = msg.value;
    }

    /// @notice placing a buy order
    /// @param price what price u want to buy
    function orderBuy(uint price) public payable {
        require(block.timestamp < deadline);
        require(msg.value > 0);
        require(price > 0);
        require(price < 100);
        uint amount = msg.value / price;
        counter++;
        orders[counter] = Order(msg.sender, OrderType.Buy, amount, price);
        emit OrderPlaced(counter, msg.sender, OrderType.Buy, amount, price);
    }

    /// @notice placing a sell order
    /// sell how many shares(amount), at which price (price)
    function orderSell(uint price, uint amount) public {
        require(block.timestamp < deadline);
        require(shares[msg.sender] >= amount);
        require(price >= 0);
        require(price <= 100);

        // shares decrese here
        shares[msg.sender] -= amount;
        counter++;
        orders[counter] = Order(msg.sender, OrderType.Sell, amount, price);
        emit OrderPlaced(counter, msg.sender, OrderType.Sell, amount, price);
    }

    /// @notice fill the sell trade
    function tradeBuy(uint orderId) public payable {
        Order storage order = orders[orderId];
        require(block.timestamp < deadline);
        require(order.user != msg.sender);
        require(order.orderType == OrderType.Sell);
        require(order.amount > 0);
        require(msg.value > 0);
        require(msg.value <= order.amount * order.price);

        uint amount = msg.value / order.price;
        uint fee = (amount * order.price) * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        uint feeShares = amount * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;

        // buyer gets all shares but the fee for owner
        shares[msg.sender] += (amount - feeShares);
        shares[owner] += feeShares;

        // seller gets all balances but the fee for owner
        balances[order.user] += (amount * order.price) - fee;
        balances[owner] += fee;

        // if order.amount == 0, then the order is done
        order.amount -= amount;
        if (order.amount == 0){
            delete orders[orderId];
        }

        emit TradeMatched(orderId, msg.sender, amount);
    }

    /// @notice fill the buy trade
    function tradeSell(uint orderId, uint amount) public payable {
        Order storage order = orders[orderId];
        require(block.timestamp < deadline);
        require(order.user != msg.sender);
        require(order.orderType == OrderType.Buy);
        require(order.amount > 0);
        require(amount <= order.amount);
        require(shares[msg.sender] >= amount);

        uint fee = (amount * order.price) * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        uint feeShares = amount * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        // seller transfer his shares to orderer but the fee to owner
        shares[msg.sender] -= amount;
        shares[order.user] += (amount - feeShares);
        shares[owner] += feeShares;

        // seller get his balance from order but the fee to owner
        balances[msg.sender] += (amount * order.price) - fee;
        balances[owner] += fee;

        // if order.amount == 0, then the order is done
        order.amount -= amount;
        if (order.amount == 0){
            delete orders[orderId];
        }
        emit TradeMatched(orderId, msg.sender, amount);
    }

    /// @notice cancel the order
    function cancelOrder(uint orderId) public {
        Order storage order = orders[orderId];
        require(order.user == msg.sender);
        if(order.orderType == OrderType.Buy) {
            balances[msg.sender] += order.amount * order.price;
        }else{
            shares[msg.sender] += order.amount;
        }
        delete orders[orderId];
        emit OrderCanceled(orderId);
    }

    /// @notice if the market resovled to no, collateral will pay back
    /// to the creater.
    function resolve(bool _result) public {
        require(block.timestamp > deadline);
        require(msg.sender == owner);
        require(result == Result.Open);
        result = _result ? Result.Yes : Result.No;
        if(result == Result.No){
            balances[owner] += collateral;
        }
    }

    /// @notice withdraw his balance
    function withdraw() public {
        uint payout = balances[msg.sender];
        balances[msg.sender] = 0;
        if (result == Result.Yes){
            payout += shares[msg.sender] * 100;
            shares[msg.sender] = 0;
        }
        payable(msg.sender).transfer(payout);
        emit Payout(msg.sender, payout);
    }

    /// @notice fund the contract
    function fund() public payable {}
}