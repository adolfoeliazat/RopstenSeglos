

pragma solidity ^0.4.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract CoinbasePriceTicker is usingOraclize {

      address Admin;
      mapping ( uint => uint ) public ETHUSD; // timestamp to price
      uint[] public Timestamp;

      event newOraclizeQuery(string description);
      event newPriceTicker(uint price, uint time);

      function CoinbasePriceTicker() payable {
        Admin = msg.sender;
        update();
      }

      function getCurrentTimestamp() constant returns (uint currentTimestamp) {
        return Timestamp[Timestamp.length - 1];
      }

      function getTimestampLength() constant returns (uint timestampLength) {
        return Timestamp.length;
      }

      function getCurrentPrice() constant returns(uint currentPrice){
        return ETHUSD[getCurrentTimestamp()];
      }

      function getPrice(uint _time) constant returns (uint price){
        return ETHUSD[_time];
      }

      function allowedToCallUpdate() constant returns (bool permission) {
        if (now > getCurrentTimestamp() + 15 minutes)
          return true;
        return false;
      }

      function callUpdate() payable {
        if (allowedToCallUpdate())
            update();
      }

      function update() private {
        if (oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            oraclize_query(300, "URL", "json(https://api.coinmarketcap.com/v1/ticker/ethereum/).0.price_usd");
        }
      }

      function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        Timestamp.push(now);
        ETHUSD[now] = parseInt(result, 5);
        newPriceTicker(getCurrentPrice(), now);
        update();
      }

      function withdraw(){
        if (msg.sender != Admin)
          throw;
        if(!Admin.send(this.balance))
          throw;
      }

      function() payable {}

}
