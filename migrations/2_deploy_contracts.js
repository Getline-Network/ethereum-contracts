var MathContract = artifacts.require("./common/Math.sol");
var InvestorLedger = artifacts.require("./loans/InvestorLedger.sol");
var Loan = artifacts.require("./loans/Loan.sol");
var MockAtestor = artifacts.require('./loans/MockAtestor.sol');
var BasicToken = artifacts.require('./tokens/BasicToken.sol');

module.exports = function(deployer) {
  var atestor = deployer.deploy(MockAtestor, true);
  var token = deployer.deploy(BasicToken, 1000000, "Basic", 0, "BAS");

  deployer.deploy(MathContract);
  deployer.link(MathContract, InvestorLedger);

  deployer.deploy(InvestorLedger);
  deployer.link(InvestorLedger, Loan);
};
