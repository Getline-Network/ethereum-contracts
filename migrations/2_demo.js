var MathContract = artifacts.require("./common/Math.sol");
var InvestorLedger = artifacts.require("./loans/InvestorLedger.sol");
var Loan = artifacts.require("./loans/Loan.sol");
var MockAtestor = artifacts.require('./loans/MockAtestor.sol');
var PrintableToken = artifacts.require('./tokens/PrintableToken.sol');
var AutoInvestor = artifacts.require('./demo/AutoInvestor.sol');
var ThreePrint = artifacts.require('./demo/ThreePrint.sol');

module.exports = function(deployer) {
  var collateralToken = null;
  var tokenA = null;
  var tokenB = null;
  return deployer
    .deploy(MathContract)
    .then(() => deployer.link(MathContract, InvestorLedger))
    .then(() => deployer.deploy(InvestorLedger))
    .then(() => deployer.link(InvestorLedger, Loan))
    .then(() => deployer.deploy(MockAtestor, true))
    .then(() =>
      Promise.all([
        deployer.deploy(PrintableToken, "Getline Test Collateral", 4, "GTC", 1000000),
        deployer.deploy(PrintableToken, "Getline Test Token A", 4, "GTA", 1000000),
        deployer.deploy(PrintableToken, "Getline Test Token B", 4, "GTB", 1000000)
      ]))
    .then((tokens) => {
      collateralToken = tokens[0];
      tokenA = tokens[1];
      tokenB = tokens[2];
      return deployer.deploy(ThreePrint, collateralToken, tokenA, tokenB);
    })
    .then(() => deployer.deploy(AutoInvestor, collateralToken, tokenA, tokenB));
};
