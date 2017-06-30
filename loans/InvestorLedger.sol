pragma solidity ^0.4.12;

import "../tokens/IToken.sol"

// TODO: Safe math

library InvestorLedger {
    uint constant PERMIL = 1000;

    function openAccount(
            IToken collateralToken,
            IToken loanToken,
            address liege,
            uint256 totalLoanNeeded,
            uint16 interestPermil) returns (Ledger account) {
        account.collateralToken = collateralToken;
        account.loanToken = loanToken;

        account.liege = liege;

        return account;
    }

    function gatherCollateral(Ledger storage account)  {
        var allowance = account.collateralToken.allowance(liege, this);
        account.totalCollateral += allowance;
        require(account.collateralToken.transferFrom(
            liege,
            this,
            allowance));
    }

    function gatherInvestment(Ledger storage account, address trustee) {
        var investmentAmount = min(
            account.loanToken.allowance(trustee, this),
            account.totalLoanNeeded - totalAmountGathered
        );
        var investmentPermil = investmentAmount * PERMIL / account.totalLoanNeeded;
        var collateralReseverved = investmentPermil * totalCollateral / PERMIL;
        
        account.totalAmountGathered += investmentAmount;
        account.totalCollateralReserved += collateralReseverved;
        account.totalPaybackNeeded += calculateInterest(account, investmentAmount);

        var investor = account.investors[trustee];
        investor.amountInvested += investmentAmount;
        investor.reservedCollateral += collateralReseverved;
    }

    function gatherPayback(Ledger storage account) {
        require(!account.loanCancelled && !account.loanDefaulted);

        require(account.loanToken.allowance(account.liege, this) >= account.totalPaybackNeeded);
        require(account.loanToken.transferFrom(account.liege, this, account.totalPaybackNeeded));

        collateralToLiege(account);
    }

    function markCancelled(Ledger storage account) {
        require(!account.loanCancelled && !account.loanDefaulted);

        account.loanCancelled = true;

        collateralToLiege(account);
    }

    function markDefaulted(Ledger storage account) {
        require(!account.loanCancelled && !account.loanDefaulted);

        account.loanDefaulted = true;

        collateralToLiege(account);
    }

    function collateralToLiege(Ledger storage account) {
        var amountToTransfer = account.totalCollateral;
        if (account.loanDefaulted) {
            amountToTransfer -= account.totalCollateralReserved;
        }
        require(account.collateralToken.transfer(account.liege, amountToTransfer));
    }

    function withdrawInvestment(Ledger storage account, address trustee) {
        var investor = account.investors[trustee];
        
        if (account.loanDefaulted) {
            var reservedCollateral = investor.reservedCollateral;
            investor.reservedCollateral = 0;
            require(account.collateralToken.transfer(trustee, reservedCollateral));
        } else {
            var amountInvested = investor.amountInvested;
            if (!account.loanCancelled) {
                amountInvested += calculateInterest(account, amountInvested);
            }
            investor.amountInvested = 0;
            require(account.loanToken.transfer(trustee, amountInvested));
        }

        delete investor;
    } 

    function isFullyFunded(Ledger storage account) constant returns (bool) {
        return account.totalAmountGathered == account.totalLoanNeeded;
    }

    function calculateInterest(Ledger storage account, uint256 investment) constant returns (uint256) {
        return investment * account.interestPermil / PERMIL;
    }

    struct Ledger {
        // Config
        IToken collateralToken;
        IToken loanToken;

        address liege;
        uint256 totalCollateral;
        uint256 totalLoanNeeded;
        uint16  interestPermil;
        uint256 paybackDeadlineBlock;
        mapping(address => InvestorData) investors;

        uint256 totalAmountGathered;

        uint256 totalCollateralReserved;
        uint256 totalPaybackNeeded;
        
        bool loanCancelled;
        bool loanDefaulted;
    }

    struct InvestorData {
        uint256 reservedCollateral;
        uint256 amountInvested;
    }
}
