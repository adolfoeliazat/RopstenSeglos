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
    uint public liquidityPool; // the ammount of ETH availble to be lent out
    uint public loanId;
    uint public loanMinimum;
    uint public loanMaximum;

    struct Loan { // loan instance assigned to a user
      address user;
      uint lev;  // leverage on the loan
      uint eth;  // size of the loan in wei
      uint time; // time at which the loan was created
      uint exit; // time at which the loan was exited
    }

    mapping ( address => uint[] ) private listOfLoans; // to find the list of a users loans
    mapping ( uint => loan ) private Loans; // loanId => loan instance

    event borrowLoanEvent(address user, uint loanId);
    event paybackLoanEvent(address user, uint loanId);

    modifier AdminOnly(){
      require (msg.sender == Admin);
      _;
    }

    function Seglos() {
      Admin = msg.sender;
      liquidityPool = 0;
      loanId = 0;
      ExchangeOpen = true;
      loanMinimum = 100 finney;
      loanMaximum = 10 ether;
      PriceContract = CoinbasePriceTicker("0x1A3f9356356b9423BFb465316e889EBBEBEde1ED");
    }

    /*
     *  Creates the loan by subtracting a fee and recording loan data
    */
    function borrowLoan(uint _leverage) payable {

      uint fee = msg.value * Fee / 100000;
      uint eth = msg.value - fee;

      require (ExchangeOpen)

      require (_leverage == 2 || _leverage == 3 || _leverage == 4)

      require (eth >= loanMinimum || eth <= loanMaximum)

      require (liquidityPool >= eth * (_leverage - 1))

      // borrow Ethereum from the fund
      liquidityPool -= eth * (_leverage - 1);

      liquidityPool += fee;

      loanId++;

      Loans[loanId] = Loan(msg.sender, _leverage, eth*_leverage, getCurrentTimestamp(), 0);

      listOfLoans[msg.sender].push(loanId);

      createloanEvent(msg.sender, loanId);
    }

    /*
     * Distributes profits and loses from the loan to the user and fund
    */
    function paybackLoan(uint _loanId) {

      Loan loan = Loans[_loanId];
      bool marginCall = false;

      // prevent high frequency trading
      require (now > loan.time + 15 minutes)

      require (loan.exit == 0)

      loan.exit = getCurrentTimestamp();

      if (getCurrentPrice() <= getPrice(loan.time)*(1/loan.lev))
        marginCall = true;

      require (msg.sender == loan.user || msg.sender == Admin || marginCall)

      if (marginCall){

        liquidityPool = liquidityPool + loan.eth;

      }else {

        // Formula that calculates the profit and loss of the user and fund
        
        uint fundEth =  loan.eth * getPrice(loan.time) * (loan.lev - 1) / (loan.lev * getCurrentPrice());

        liquidityPool += fundEth;

        uint userEth = loan.eth - fundEth;

        bool sent = loan.user.send(userEth);

        require (sent);

      }

      exitloanEvent(loan.user, _loanId);
    }

    /*
     * Constant functions
     * Provides information for the user interface
    */

    function getUserList() constant returns (uint[]) {
      return listOfLoans[msg.sender];
    }

    function getLoan(uint loanId) constant returns (uint lev, uint eth, uint time, uint exit) {
      Loan loan = Loans[loanId];
      return (loan.lev, loan.eth, loan.time, loan.exit );
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
