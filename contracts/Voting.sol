// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Voting {

    event ProposalCreated(uint _proposalId);
    event BecomeMember(string note);
    event VoteCast (uint _proposalId, address indexed _voter);

    enum VoteStates {Absent, Yes, No}

    uint constant minimumVotes =10;
    uint public  memberFee = 0.5 ether;
    address public validator;

    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        bool executedProposal;
        mapping (address => VoteStates) voteStates;
    }
    
    Proposal[] public proposals;

    mapping(address => bool) approvedMembers;

    address[] pendingMembers;

    constructor(address[] memory _approvedMembers) {
        validator= msg.sender;
        for(uint i=0; i< _approvedMembers.length; i++) {
            approvedMembers[_approvedMembers[i]] = true;
        }
        approvedMembers[msg.sender]= true;

    }
    
    function newProposal(address _target, bytes calldata _data) external {
        require(approvedMembers[msg.sender], "You are not member");
        Proposal storage proposal = proposals.push();
        proposal.target = _target;
        proposal.data = _data;
        emit ProposalCreated(proposals.length-1);
    }

    function becomeMember() external payable{
        require(msg.value == 0.5 ether, "pay valid value");
        require(!approvedMembers[msg.sender], "You are Already Member");
        pendingMembers.push(msg.sender);
        emit  BecomeMember("request for membership is submitted");
    }

    function approveAllMembers() external {
        for(uint i=0; i<pendingMembers.length;i++){
            approvedMembers[pendingMembers[i]]= true;
            delete pendingMembers[i];
        }

    }
    
    function castVote(uint _proposalId, bool _choice) external {
        require(approvedMembers[msg.sender], "You are not member");
        require(msg.sender != proposals[_proposalId].target, "Proposal Owner can't cast vote");
        Proposal storage proposal = proposals[_proposalId];

        // clear out previous vote 
        if(proposal.voteStates[msg.sender] == VoteStates.Yes) {
            proposal.yesCount--;
        }
        if(proposal.voteStates[msg.sender] == VoteStates.No) {
            proposal.noCount--;
        }

        // add new vote 
        if(_choice) {
            proposal.yesCount++;
        }
        else {
            proposal.noCount++;
        }

        proposal.voteStates[msg.sender] = _choice ? VoteStates.Yes : VoteStates.No;
        emit VoteCast(_proposalId, msg.sender);

        if(proposal.yesCount == minimumVotes && !proposal.executedProposal) {
        (bool success, ) = proposal.target.call(proposal.data);
        require(success, "Transaction Failed");
        proposal.executedProposal=true;
        }
    }
}