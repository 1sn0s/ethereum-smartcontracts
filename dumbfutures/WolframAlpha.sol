/*
   This contract gets the necessary information from wolfram aplpha based on the query
*/
pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract WolframAlpha is usingOraclize {
    
    string public price;
    
    event newOraclizeQuery(string description);
    event newStockPrice(string stockPrice);

    function WolframAlpha() {
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        price = result;
        stockPrice(price);
        // do something with the temperature measure..
    }

    function getData(string query){
        update(query);
    }
    
    function update(string query) payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("WolframAlpha", query);
    }
    
} 
                                           
