pragma solidity ^0.4.10;

contract CoinbasePriceTicker {
      function getCurrentTimestamp() constant returns (uint);
      function getPrice(uint) constant returns (uint);
      function getCurrentPrice() constant returns(uint);
}

contract Seglos{

    address Admin;
    CoinbasePriceTicker public PriceContract;
    bool public ExchangeOpen;
    uint public Fee;
    uint public liquidityPool; // the ammount availble to be lend out
    uint public tradeId;
    uint public tradeMinimum;
    uint public tradeMaximum;

    struct Trade { // trade instance assigned to a user
      address user;
      uint lev;  // leverage on the trade
      uint eth;  // size of the trade in wei
      uint time; // time at which the trade was created
      uint exit; // time at which the trade was exited
    }

    mapping ( address => uint[] ) private listOfTrades; // to find the list of a users trades
    mapping ( uint => Trade ) private trades; // tradeId => Trade instance

    event createTradeEvent(address user, uint tradeId);
    event exitTradeEvent(address user, uint tradeId);

    modifier AdminOnly(){
      require (msg.sender == Admin);
      _;
    }

    function Seglos() {
      Admin = msg.sender;
      liquidityPool = 0;
      tradeId = 0;
      ExchangeOpen = true;
      tradeMinimum = 100 finney;
      tradeMaximum = 10 ether;
      PriceContract = CoinbasePriceTicker("0x1A3f9356356b9423BFb465316e889EBBEBEde1ED");
    }

    /*
     *  Creates the trade by subtracting a fee and recording trade data
    */
    function createTrade(uint _leverage) payable {

      uint fee = msg.value * Fee / 100000;
      uint eth = msg.value - fee;

      require (ExchangeOpen)

      require (_leverage == 2 || _leverage == 3 || _leverage == 4)

      require (eth >= tradeMinimum || eth <= tradeMaximum)

      require (liquidityPool >= eth * (_leverage - 1))

      // borrow Ethereum from the fund
      liquidityPool -= eth * (_leverage - 1);

      liquidityPool += fee;

      tradeId++;

      trades[tradeId] = Trade(msg.sender, _leverage, eth*_leverage, getCurrentTimestamp(), 0);

      listOfTrades[msg.sender].push(tradeId);

      createTradeEvent(msg.sender, tradeId);
    }

    /*
     * Distributes profits and loses from the trade to the user and fund
    */
    function exitTrade(uint _tradeId) {

      Trade trade = trades[_tradeId];
      bool marginCall = false;

      // prevent high frequency trading
      require (now > trade.time + 15 minutes)

      require (trade.exit == 0)

      trade.exit = getCurrentTimestamp();

      if (getCurrentPrice() <= getPrice(trade.time)*(1/trade.lev))
        marginCall = true;

      require ((msg.sender == trade.user || msg.sender == Admin) || marginCall)

      if (marginCall){

        liquidityPool = liquidityPool + trade.eth;

      }else {

        // Formula that calculates the profit and loss of the user and fund
        uint fundEth =  trade.eth * getPrice(trade.time) * (trade.lev - 1) / (trade.lev * getCurrentPrice());

        liquidityPool += fundEth;

        uint userEth = trade.eth - fundEth;

        bool sent = trade.user.send(userEth);

        require (sent);

      }

      exitTradeEvent(trade.user, _tradeId);
    }

    /*
     * Constant functions
     * Provides information for the user interface
    */

    function getUserList() constant returns (uint[]) {
      return listOfTrades[msg.sender];
    }

    function getTrade(uint tradeId) constant returns (uint lev, uint eth, uint time, uint exit) {
      Trade trade = trades[tradeId];
      return (trade.lev, trade.eth, trade.time, trade.exit );
    }

    function getCurrentPrice() constant returns (uint currentPrice) {
      return PriceContract.getCurrentPrice();
    }

    function getPrice(uint _time) constant returns (uint price) {
      return PriceContract.getPrice(_time);
    }

    function getCurrentTimestamp() constant returns (uint currentTimestamp){
      return PriceContract.getCurrentTimestamp();
    }

    /*
     * Administrative functions
    */

    function Door(bool _door) AdminOnly {
      ExchangeOpen = _door;
    }

    function setFee(uint _fee) AdminOnly {
      Fee = _fee;
    }

    function depositLiquidity() payable AdminOnly {
      liquidityPool = liquidityPool + msg.value;
    }

    function withdrawLiquidity(uint _eth) AdminOnly {
      require (liquidityPool >= _eth)

      liquidityPool -= _eth;

      require (msg.sender.send(_eth))
    }
}
