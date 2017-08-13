pragma solidity ^0.4.11;

import "../tokens/PrintableToken.sol";

// Prints three printable tokens at once
contract ThreePrint {
    PrintableToken tokenA;
    PrintableToken tokenB;
    PrintableToken tokenC;

    function ThreePrint(
        PrintableToken _tokenA,
        PrintableToken _tokenB,
        PrintableToken _tokenC
    ) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        tokenC = _tokenC;
    }

    function print(address _who) {
        tokenA.print(_who);
        tokenB.print(_who);
        tokenC.print(_who);
    }
}