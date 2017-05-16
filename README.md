# Seglos Demo (Ropsten Deployment)
Smart Contracts for the Seglos DAPP located at: [www.seglos.com/app](http://www.seglos.com/app) 

### Exchange.sol
Responsbile for creating trades and providing information to the user interface. Two most important functions are `createTrade(uint _leverage)` and `exitTrade(uint _tradeId)`  

Deployed at: 0x  


### Price.sol
Retrives the current ETH/USD exchange rate from [coinmarketca](http://coinmarketcap.com/currencies/ethereum/) Using [Oraclize](http://www.oraclize.it/) which securely puts that data on the blockchain to be used by Exchange.sol

Deployed at: 0x
