/* from https://www.ethereum.org/token */

pragma solidity ^0.4.11;

import "./IToken.sol";

contract BasicToken is IToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 private totalSupplyField;

    /* This creates an array with all balances */
    mapping (address => uint256) private balanceOfField;
    mapping (address => mapping (address => uint256)) private allowanceField;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        balanceOfField[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupplyField = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    function totalSupply() constant returns (uint256 totalSupply) {
        return totalSupplyField;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOfField[_owner];
    }

    function allowance(address _owner, address _spender) constant returns (uint256 allowance) {
        return allowanceField[_owner][_spender];
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOfField[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOfField[_to] + _value < balanceOfField[_to]) throw; // Check for overflows
        balanceOfField[msg.sender] -= _value;                     // Subtract from the sender
        balanceOfField[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowanceField[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }      

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;                                // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOfField[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOfField[_to] + _value < balanceOfField[_to]) throw;  // Check for overflows
        if (_value > allowanceField[_from][msg.sender]) throw;     // Check allowance
        balanceOfField[_from] -= _value;                           // Subtract from the sender
        balanceOfField[_to] += _value;                             // Add the same to the recipient
        allowanceField[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
}