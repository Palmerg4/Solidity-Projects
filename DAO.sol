// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.8.5;

/**
 * @title DAO Example
 * @author Gordy Palmer
 * @dev Investment platform based on the DAO allowing an investor-directed
 * venture capital fund, as opposed to with a fund manager. Ability for investors to
 * vote on proposals and recieve shares based on invested amount.
 */

contract DAO {
    
    struct Proposal {
        uint id;
        string name;
        uint amount;
        address payable recipient;
        uint votes;
        uint end;
        bool executed;
    }
    mapping(address => bool) public investors;
    mapping(address => uint) public shares;
    mapping(uint => Proposal) public proposals;
    mapping(address => mapping(uint => bool)) public votes;
    uint public totalShares;
    uint public availableFunds;
    uint public contributionEnd;
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public admin;
    
    constructor(
        uint contributionTime,
        uint _voteTime,
        uint _quorum){
        require(_quorum > 0 && _quorum < 100, 'Quorum must be below 100% and above 0%');
        contributionEnd = block.timestamp + contributionTime;
        voteTime = _voteTime;
        quorum = _quorum;
        admin = msg.sender;
    }
    
    ///@dev Ability to invest with specified amount, before the end of contribution window.
    
    function contribute() payable external {
        require(block.timestamp < contributionEnd, 'Cannot contribute after contributionEnd');
        investors[msg.sender] = true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }
    
    ///@dev Ability to redeem ones shares after investment.
    
    function redeemShare(uint amount, address payable _recipient) external {
        require(msg.sender == _recipient);
        require(shares[_recipient] >= amount, 'Not enough shares');
        require(availableFunds >= amount, 'Not enough availableFunds');
        shares[_recipient] -= amount;
        availableFunds -= amount;
        _recipient.transfer(amount);
    }
    
    ///@dev Ability to transfer shares to another investor.
    ///Used to sell shares from one investor to another who missed initial investment window.

    function transferShare(uint amount, address to) external {
        require(shares[msg.sender] >= amount, 'Not enough shares');
        shares[msg.sender] -= amount;
        shares[to] += amount;
        investors[to] = true;
    }
    
    ///@dev Ability for an investor to create an investment proposal for the group.
    
    function createProposal(
        string calldata name,
        uint amount,
        address payable recipient)
        external onlyInvestors() {
            require(availableFunds >= amount, 'Amount too large');
            proposals[nextProposalId] = Proposal(
                nextProposalId,
                name,
                amount,
                recipient,
                0,
                block.timestamp + voteTime,
                false
            );
            availableFunds -= amount;
            nextProposalId++;
        }
        
    ///@dev Ability for investors to vote on proposals created with createProposal.    
        
    function vote(uint proposalId) external onlyInvestors() {
        Proposal storage proposal = proposals[proposalId];
        require(votes[msg.sender][proposalId] == false, 'Investor can only vote once per proposal');
        require(block.timestamp < proposal.end, 'Proposal has closed');
        votes[msg.sender][proposalId] = true;
        proposal.votes += shares[msg.sender];
    }
    
    ///@dev Ability for the admin to execute the proposal, if voting has passed for the specific proposal.
    
    function executeProposal(uint proposalId) external onlyAdmin() {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.end, 'Cannot execute a proposal before end date');
        require(proposal.executed == false, 'Cannot execute a proposal already executed');
        require((proposal.votes / totalShares) * 100 >= quorum, 'Cannot execute proposal with votes < quorum');
        _transferEther(proposal.amount, proposal.recipient);
    }
    
    function withdrawEther(uint amount, address payable to) external onlyAdmin() { 
        _transferEther(amount, to);
    }
    
    fallback() payable external {
        availableFunds += msg.value;
    }
    
    function _transferEther(uint amount, address payable to) internal {
        require(amount <= availableFunds, 'Not enough avaiable funds');
        availableFunds -= amount;
        to.transfer(amount);
    }
    
    modifier onlyInvestors() {
        require(investors[msg.sender] == true, 'Only investors');
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, 'Only admin');
        _;
    }
}