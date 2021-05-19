// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.8.5;

/** 
 * @title Escrow
 * @author Gordy Palmer
 * @dev Escrow contract to hold funds designated for a payee until they
 * withdraw them.
 */

contract Escrow {
    address public payer;
    address payable public payee;
    address public lawyer;
    uint public amount;
    
    constructor(
        address _payer, 
        address payable _payee,
        uint _amount
        ){
            
            payer = _payer;
            payee = _payee;
            lawyer = msg.sender;
            amount = _amount;
        }
        
        ///@dev Deposit function for payer to use.
        
        function deposit() payable public {
            require(msg.sender == payer, 'Sender must be the payer');
            require(address(this).balance <= amount);
        }
        
        ///@dev Release function for legal party use. In this case, a lawyer.
        
        function release() public {
            require(address(this).balance == amount, 'cannot relese funds before full amount is sent');
            require(msg.sender == lawyer, 'only lawyer can release funds');
            payee.transfer(amount);
        }
        
        function balanceOf() view public returns(uint) {
            return address(this).balance;
        }
        
        
        
        
}