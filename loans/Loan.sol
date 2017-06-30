pragma solidity ^0.4.12;

import "./IAtestor.sol"
import "./InvestorLedger.sol"
import "../tokens/IToken.sol"

contract Loan {
    // Set only during begining phases and not changed afterwards
    uint256 public fundraisingBlocksCount;
    uint256 public paybackBlocksCount;

    // Contract changing state
    uint256 public fundraisingDeadline = 0;
    uint256 public paybackDeadline = 0;
    State   public currentState = State.CollateralCollection;
    
    using InvestorLedger for InvestorLedger.Ledger;
    InvestorLedger.Ledger ledger;   

    event FundraisingBegins(address indexed liege);
    event NewInvestment(address indexed liege, address indexed trustee);
    event FundraisingSucessfull(address indexed liege);
    event FundraisingFailed(address indexed liege);
    event LoanPaidback(address indexed liege);
    event LoanDefaulted(address indexed liege);

    modifier atState(State _state) {
        require(currentState == _state);

        _;
    }

    modifier timedTransitions() {
        if (currentState == State.Fundraising && fundraisingDeadline < block.number) {
            if (ledger.isFullyFunded())
                onFundraisingSuccess();
            else
                onFundraisingFail();
        } else if (currentState == State.Payback && paybackDeadline < block.number) {
            onPaybackFailure();
        }

        _;
    }

    function Loan(
            IAtestor _atestator,
            IToken _collateralToken,
            IToken _loanToken,
            address _liege,
            uint256 _amountWanted,
            uint16  _interestPermil,
            uint256 _fundraisingBlocksCount,
            uint256 _paybackBlocksCount
            ) {
        require(_atestator.isVerified(liege))
        
        ledger = InvestorLedger.openAccount(
            _collateralToken,
            _loanToken,
            _liege,
            _amountWanted,
            _interestPermil
        );
        
        fundraisingBlocksCount = _fundraisingBlocksCount;
        paybackBlocksCount = _paybackBlocksCount;
    }

    function gatherCollateral() atState(State.CollateralCollection) {
        ledger.gatherCollateral();

        currentState = State.Fundraising;
        fundraisingDeadline = block.number + fundraisingBlocksCount;

        FundraisingBegins(liege);
    }

    function invest() timedTransitions atState(State.Fundraising) {
        ledger.gatherInvestment(msg.sender);

        NewInvestment(liege, trustee);
    }

    function payback() timedTransitions atState(State.Payback) {
        ledger.gatherPayback();
        currentState = State.Finished;

        onPaybackSucess();
    }

    function widthrawInvestment() timedTransitions atState(State.Finished) {
        ledger.widthrawInvestment();
    }

    function onFundraisingSuccess() private {
        paybackDeadline = block.number + paybackBlocksCount;
        currentState = State.Payback;
        
        FundraisingSucessfull(liege);
    }

    function onFundraisingFail() private {
        ledger.markCancelled();
        currentState = State.Finished;

        FundraisingFailed(liege);
    }

    function onPaybackSucess() private {
        currentState = State.Finished;

        LoanPaidback(liege);
    }

    function onPaybackFailure() private {
        ledger.markDefaulted();
        currentState = State.Finished;

        LoanDefaulted(liege);
    }

    enum State {
        CollateralCollection,
        Fundraising,
        Payback,
        Finished
    }
}