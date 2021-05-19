// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.8.5;

/**
 * @title SplitPayment
 * @author Gordy Palmer
 * @dev Payment system intended for transfering from one address to multiple addresses 
 */

contract SplitPayment {
    address public owner;
    
    constructor(address _owner){
        owner = _owner;
    }
    
     //@dev Sends amount specified to address specified.
     
    function send(address payable[] memory to, uint[] memory amount) payable onlyOwner() public {
       
        require(to.length == amount.length, 'to and amount arrays must have same length');
        for(uint i = 0; i < to.length; i++) {
           to[i].transfer(amount[i]);
       }
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, 'only owner can send transfer');
        _;
        
    }
}
