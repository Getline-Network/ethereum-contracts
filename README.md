## Uber quick quickstart
```
npm install -g truffle
npm install -g testrpc
testrpc
truffle deploy
```
Done.

Currently also working with deployments on Kovan test-network, install parity and get some Ether from faucets to have fun with that.

## Using deployed tokens
Truffle-Contract is a wrapper for normal web3 apis that the Ethereum uses.
It allows for easy usage and deployments on multiple networks, example being

```javascript
var LoanDefinition = require('build/Loan.json');
var contract = require('truffle-contract');

var LoanClass = contrat(LoanDefinition);
LoanClass.new(...parameters).then(console.log);
```

## Caveats
Truffle Framework doesn't support multiple instances of a single token, and thus 3 tokens for the demo won't be saved into build/*.json config file, better save that info somewhere during deployment.