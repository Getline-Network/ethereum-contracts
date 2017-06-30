pragma solidity ^0.4.12;

interface IAtestor {
    function isVerified(address _checkedUser) constant returns (bool success);
    // TODO: Maybe percentage of trust to collect it at the time of loan creation?
}
