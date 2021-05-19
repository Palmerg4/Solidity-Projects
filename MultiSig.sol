// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.8.5;

/**
 * @title Multisignature Wallet
 * @author Gordy Palmer
 * @dev Multiple approvals needed to send transaction from 'protected' wallet. Transaction will not send 
 * until specified amount of approvals needed is met.
 */

contract MultiSig {
    address[] public approvers;
    uint public quorum;
    struct Transfer {
        uint id;
        uint amount;
        address payable to;
        uint approvals;
        bool sent;
    }
    mapping(uint => Transfer) transfers;
    uint nextId;
    mapping(address => mapping(uint => bool)) approvals;
    
    constructor(address[] memory _approvers, uint _quorum)
    payable {
        approvers = _approvers;
        quorum = _quorum;
    }
    
    ///@dev Any approver may create a possible transaction, to be reviewed by other approvers.
    
    function createTransfer(uint amount, address payable to) 
        external
        onlyApprover()
        {
            transfers[nextId] = Transfer(
                nextId,
                amount,
                to,
                0,
                false
            );
            nextId++;
            
        }
        
    ///@dev Ability to send the transaction if enough approvers agree.     
        
    function sendTransfer(uint id) external onlyApprover() {
        require(transfers[id].sent == false, 'transfer has already been sent');
        if(transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint amount = transfers[id].amount;
            to.transfer(amount);
            return;
        }
        if(approvals[msg.sender][id] == false) {
            approvals[msg.sender][id] = true;
            transfers[id].approvals++;
        }
        
    }
    
    modifier onlyApprover() {
        bool allowed = false;
        for(uint i=0; i < approvers.length; i ++) {
            if(approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, 'Only approver allowed');
        _;
    }
}
