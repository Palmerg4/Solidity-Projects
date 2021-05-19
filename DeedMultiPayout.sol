// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @title DeedMultiPayout
 * @author Gordy Palmer
 * @dev Deed payout system designed for a beneficiary to recieve scheduled payouts from 
 * source. In this case, a lawyer.
 */

contract Deed {
    address public lawyer;
    address payable public beneficiary;
    uint public earliest;
    uint public amount;
    uint constant public PAYOUTS = 10;
    uint constant public INTERVAL = 10;
    uint public paidPayouts;
    
    constructor(
        address _lawyer,
        address payable _beneficiary,
        uint fromNow)
        payable {
            lawyer = _lawyer;
            beneficiary = _beneficiary;
            earliest = block.timestamp + fromNow;
            amount = msg.value / PAYOUTS;
        }
        
        function withdraw() public {
            require(msg.sender == beneficiary, 'Beneficiary only');
            require(block.timestamp >= earliest, 'too early');
            require(paidPayouts < PAYOUTS, 'no payouts left');
            
            /**
            * @dev Withdraw function for beneficiary accessing payment.
            * @param beneficiary The party entitled to withdraw specified amounts at specified times.
            */
            
            
            uint elligiblePayouts = (block.timestamp - earliest) / INTERVAL;
            uint duePayouts = elligiblePayouts - paidPayouts;
            duePayouts = duePayouts + paidPayouts > PAYOUTS ? PAYOUTS - paidPayouts : duePayouts;
            paidPayouts += duePayouts;
            beneficiary.transfer(duePayouts * amount);
        }
        
}