// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable{

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }
    WorkflowStatus private  state;

    constructor() Ownable(msg.sender){ 
        state = WorkflowStatus.VotesTallied;  
    }

    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event VoterRegistered(address voterAddress);   
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);


    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    
    struct Proposal {
        string description;
        uint voteCount;
    }

    mapping (address => bool) whitelist; 
    mapping (address => Voter) voters; //Configuration des voters;
    Proposal[] public proposals;
    uint private whitelistCount; //Compteur de nombre d'addresse dans la whiteliste.
    Proposal[] public winners;

    //L'administrateur change la phase du processus de vente
    
    function nextVotingStatus() public onlyOwner{ //Definis le status à l'etape suivante
        WorkflowStatus previousStatus=state;

        if (state== WorkflowStatus.VotesTallied){
            state = WorkflowStatus.RegisteringVoters; //Reviens au premier état si à la fin des enum Workflow
        }else{
            state = WorkflowStatus(uint(state)+1);
        }
        WorkflowStatus newStatus=state; 
        emit WorkflowStatusChange(previousStatus, newStatus); 
    }



    //L'administrateur enregistre les adresse Ethereum sur liste blanche

    function _whitelist(address _address) public onlyOwner{
        require(state == WorkflowStatus.RegisteringVoters,"Address can be added only in Registration phase:0"); //Check que nous sommes bien dans la phase d'enregistrement des adresses
        require(!whitelist[_address],"Address already registered");//Check si l'addresse n'est pas déjà dans la whitelist

        voters[_address]= Voter({
            isRegistered:true,
            hasVoted: false,
            votedProposalId: 0
        });
        whitelist[_address]=true; //Ajoute l'addresse si elle n'est pas dans la liste

        whitelistCount++ ; //Incremente le compteur de nombre d'addresse dans la whiteliste.

        emit VoterRegistered(_address); //emet sur la blockchain l'adresse whitelisted
    }

    /* Les électeurs inscrits sont autorisés à enregistrer leurs propositions 
    pendant que la session d'enregistrement est active. */


    function _addProposal (string memory _description) external {
        require(state == WorkflowStatus.ProposalsRegistrationStarted,"Proposal can be addes only in Proposal Registration phase:1"); //Check que nous sommes bien dans la phase d'enregistrement des adresses
        require(whitelistCount>0,"Whitelist must contain at least one address");
        require(whitelist[msg.sender],"Your adress is not whitelisted");

        proposals.push(Proposal({
            description: _description,
            voteCount:0

        }));
        uint proposalId = proposals.length-1;
        emit ProposalRegistered(proposalId);

    }
    function getProposalCount() external view returns (uint){
        return proposals.length;
    }

    function getAllProposal()external view returns(Proposal[] memory){
        return proposals;
    }
    

    function Vote(uint _choice ) external {
        require(state == WorkflowStatus.VotingSessionStarted,"Proposal can be addes only in voting phase:3"); //Check que nous sommes bien dans la phase de vote des proposal
        require(proposals.length>0,"You have to get at leat one proposal in order to proceed a voting phase");
        require(voters[msg.sender].isRegistered, "You ar not registered as a voter");
        require(!voters[msg.sender].hasVoted,"You have already voted");
        require(_choice < proposals.length,"Invalid proposal choice");

        voters[msg.sender].hasVoted=true;
        voters[msg.sender].votedProposalId=_choice;
        proposals[_choice].voteCount++;

        emit Voted(msg.sender,_choice);        
    }
/* L'administrateur de vote met fin à la session d'enregistrement des propositions.

L'administrateur du vote commence la session de vote.

Les électeurs inscrits votent pour leur proposition préférée.

L'administrateur du vote met fin à la session de vote.

L'administrateur du vote comptabilise les votes.

Tout le monde peut vérifier les derniers détails de la proposition gagnante.
     */
}