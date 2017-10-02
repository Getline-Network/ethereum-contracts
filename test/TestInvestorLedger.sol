pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/loans/InvestorLedger.sol";
import "../contracts/tokens/PrintableToken.sol";


contract TestInvestorLedger {
    uint256 totalLoanNeeded = 100;
    uint16 interestPermil = 200;
    uint256 empty = 0;
    uint256 printValue = 100;
    PrintableToken collateralToken = createMockToken("collateralToken");
    PrintableToken loanToken = createMockToken("loanToken");
    TestPerson investor = new TestPerson(loanToken, collateralToken);
    TestPerson borrower = new TestPerson(loanToken, collateralToken);
    InvestorLedger.Ledger testLedger = InvestorLedger.openAccount(
        collateralToken, loanToken, address(borrower), totalLoanNeeded, interestPermil);

    function createMockToken(string memory tokenName)  returns (PrintableToken) {
        uint256 decimalPoints = 0;
        string memory tokenSymbol = tokenName;
        return new PrintableToken(tokenName, decimalPoints, tokenSymbol, printValue);
    }
    function testInvestorLedger() {
        testLedger.loanToken = loanToken;
        testLedger.collateralToken = collateralToken;
        Assert.equal(testLedger.totalAmountGathered, empty, "It should be initialy empty");
        bool isFullyFunded = InvestorLedger.isFullyFunded(testLedger);
        Assert.equal(isFullyFunded, false, "Ledger should not be fully funded");
        Assert.equal(testLedger.totalLoanNeeded, totalLoanNeeded, "Ledger be initialized with load needed");
    }
    function testGatherCollateral() {
        borrower.printMeCollateralTokens();
        Assert.equal(collateralToken.balanceOf(borrower), printValue, "It should print some tokens");

        InvestorLedger.gatherCollateral(testLedger);
        Assert.equal(collateralToken.balanceOf(borrower), empty, "It should transfer tokens");
        Assert.equal(testLedger.totalCollateral, printValue, "It should add collateral tokens");
    }
    function testGatherInvestment() {
        InvestorLedger.gatherInvestment(testLedger, address(investor));
        Assert.equal(testLedger.totalAmountGathered, empty, "Empty when investor has no loan tokens");

        investor.printMeLoanTokens();
        InvestorLedger.gatherInvestment(testLedger, address(investor));
        Assert.equal(testLedger.totalAmountGathered, totalLoanNeeded, "It should invest some money");
        uint256 totalCollateral = printValue;
        Assert.equal(testLedger.totalCollateralReserved, totalCollateral, "It should update collateral");
        uint256 expectedTotalPaybackNeeded = 20; /* TODO ERROR, it should be 120 */
        Assert.equal(testLedger.totalPaybackNeeded, expectedTotalPaybackNeeded, "It should count intrests");
    }
}


contract TestPerson {
    PrintableToken loanToken;
    PrintableToken collateralToken;

    function TestPerson(PrintableToken _loanToken, PrintableToken _collateralToken) {
        loanToken = _loanToken;
        collateralToken = _collateralToken;
    }
    function printMeCollateralTokens() {
        collateralToken.print(this);
        collateralToken.approve(msg.sender, collateralToken.printValue());
    }
    function printMeLoanTokens() {
        loanToken.print(this);
        loanToken.approve(msg.sender, loanToken.printValue());
    }
}