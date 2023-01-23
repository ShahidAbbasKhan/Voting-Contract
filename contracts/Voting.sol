// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Voting {

    event ProposalCreated(uint _proposalId);
    event VoteCast (uint _proposalId, address indexed _voter);

    enum VoteStates {Absent, Yes, No}

    uint constant minimumVotes =10;

    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        bool executedProposal;
        mapping (address => VoteStates) voteStates;
    }
    
    Proposal[] public proposals;

    mapping(address => bool) members;

    constructor(address[] memory _members) {
        for(uint i=0; i< _members.length; i++) {
            members[_members[i]] = true;
        }
        members[msg.sender]= true;

    }
    
    function newProposal(address _target, bytes calldata _data) external {
        require(members[msg.sender], "You are not member");
        Proposal storage proposal = proposals.push();
        proposal.target = _target;
        proposal.data = _data;
        emit ProposalCreated(proposals.length-1);
    }

    function castVote(uint _proposalId, bool _choice) external {
        require(members[msg.sender], "You are not member");
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
        }
    }
}