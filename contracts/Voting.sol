// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable{
    


    struct Voter {bool isRegistered; bool hasVoted; uint votedProposalID;} //Structure de données des voters
    struct Proposal {string description; uint voteCount;}//Structure de données des porposals

    enum WorkflowStatus { RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    } // Definiton des différents états d'un vote 
    
    WorkflowStatus public state = WorkflowStatus.VotesTallied;

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);

    //Définition du status initial ainsi que l'administrateur du contrat
    constructor() Ownable(msg.sender) {
        state = WorkflowStatus.VotesTallied;
    }

    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);


    //Modification du status du processus de vote
    function nextStatus() public onlyOwner{
        WorkflowStatus previousStatus = state;
        if (state == WorkflowStatus.VotesTallied){ //Retroune au début de l'enum.
            state = WorkflowStatus.RegisteringVoters;
        }else{
            state = WorkflowStatus(uint(state) + 1);
        }
        //emission de l'événement de changement d'état
        emit WorkflowStatusChange(previousStatus, state);
    }

    mapping (address => bool) _whitelisted; // Mapping des adresses whitelisted

    //Défintion de la whitelist
    function whitelist (address _address) public  onlyOwner{
        require(state == WorkflowStatus.RegisteringVoters,"whitelist can only be updated during Voter Registration phase.");
        require(!_whitelisted[_address], "Adress already whitelisted");
        _whitelisted[_address]=true;

        emit VoterRegistered(_address); //emission de l'adresse whitlisted

    }



    function winningProposalId() public{

    }
    function getWinner() public{

    }


}