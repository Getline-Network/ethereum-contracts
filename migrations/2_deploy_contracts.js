var MathContract = artifacts.require("./common/Math.sol");
var InvestorLedger = artifacts.require("./loans/InvestorLedger.sol");
var Loan = artifacts.require("./loans/Loan.sol");
var MockAtestor = artifacts.require('./loans/MockAtestor.sol');
var BasicToken = artifacts.require('./tokens/BasicToken.sol');

module.exports = function(deployer) {
  return deployer
    .deploy(MathContract)
    .then(() => deployer.link(MathContract, InvestorLedger))
    .then(() => deployer.deploy(InvestorLedger))
    .then(() => deployer.link(InvestorLedger, Loan))
    .then(() => deployer.deploy(MockAtestor, true))
    .then(() => deployer.deploy(BasicToken, 1000000, "Basic", 0, "BAS"))
    .then(() => deployer.deploy(
      Loan,
      MockAtestor.address,
      BasicToken.address,
      BasicToken.address,
      web3.eth.accounts[0],
      1000,
      100,
      5,
      5)
    );
};
