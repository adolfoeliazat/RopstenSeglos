# Seglos Demo (Ropsten Deployment)
Smart Contracts for the Seglos DAPP located at: [www.seglos.com/app](http://www.seglos.com/app) 

### Exchange.sol
Responsbile for creating loans and providing information to the user interface. Two most important functions are `borrowLoan(uint _leverage)` and `paybackLoan(uint _loanId)`  

Deployed at: [0x8f03ad84b390f1e6d2cd11960afda6bb5c1e696b](https://ropsten.etherscan.io/address/0x8f03ad84b390f1e6d2cd11960afda6bb5c1e696b#code)


### Price.sol
Retrives the current ETH/USD exchange rate from [coinmarketca](http://coinmarketcap.com/currencies/ethereum/) Using [Oraclize](http://www.oraclize.it/) which securely puts that data on the blockchain to be used by Exchange.sol

Deployed at: [0x943b6dc3dc99301fad0ab3271185afba71a5194f](https://ropsten.etherscan.io/address/0x943b6dc3dc99301fad0ab3271185afba71a5194f#code)
