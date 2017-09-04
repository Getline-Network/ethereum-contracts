var Bluebird = require('bluebird'); 

var PrintableToken = artifacts.require('./tokens/PrintableToken.sol');
var AutoInvestor = artifacts.require('./demo/AutoInvestor.sol');
var PrintableCollection = artifacts.require('./demo/PrintableCollection.sol');

var DEMO_TOKENS = [
  ["Getline Test Collateral", 4, "GTC", 1000000],
  ["Getline Test Token A", 4, "GTA", 1000000],
  ["Getline Test Token B", 4, "GTB", 1000000]
];

module.exports = function(deployer) {
  var tokenInstances = null;
  return deployer
    .then(() =>
      Bluebird.map(
        DEMO_TOKENS,
        (params) => PrintableToken.new(...params)
      )
    )
    .then((tokens) => tokenInstances = tokens)
    .then(() => PrintableCollection.new())
    .then((instance) => Bluebird.each(
      tokenInstances,
      (token) => instance.addToken(token.address))
    );
    //.then(() => deployer.deploy(AutoInvestor, ...DEMO_TOKENS));
};
