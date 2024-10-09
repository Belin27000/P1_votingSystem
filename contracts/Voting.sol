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

    constructor() Ownable(msg.sender){ //Specifie que le proprietaire du contrat et celui qui l'a deployé
        state = WorkflowStatus.VotesTallied;     //Definit l'état inital
    }

    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    
    //L'administrateur change la phase du processus de vente
    
    function nextVotingStatus() public onlyOwner{ //Definis le status à l'etape suivante
        WorkflowStatus previousStatus=state; //stock la valeur de status avant modification dans previousStatus

        if (state== WorkflowStatus.VotesTallied){
            state = WorkflowStatus.RegisteringVoters; //Reviens au premier état si à la fin des enum Workflow
        }else{
            state = WorkflowStatus(uint(state)+1);
        }
        WorkflowStatus newStatus=state; //stock la valeur de status avant modification dans previousStatus
        emit WorkflowStatusChange(previousStatus, newStatus); //Emet le changement de status du processus de vote sur la blockchain
    }

    mapping (address => bool) whitelist; //Configuration de la liste blanche des address authorisée à voter
    uint private _whitelistCount; //Compteur de nombre d'addresse dans la whiteliste.
    event VoterRegistered(address voterAddress);

    //L'administrateur enregistre les adresse Ethereum sur liste blanche

    function _whitelist(address _address) public onlyOwner{
        require(state == WorkflowStatus.RegisteringVoters,"Address can be added only in Registration phase:0"); //Check que nous sommes bien dans la phase d'enregistrement des adresses
        require(!whitelist[_address],"Address already registered");//Check si l'addresse n'est pas déjà dans la whitelist
        whitelist[_address]=true; //Ajoute l'addresse si elle n'est pas dans la liste

        _whitelistCount++;//Incremente le compteur de nombre d'addresse dans la whiteliste.

        emit VoterRegistered(_address); //emet sur la blockchain l'adresse whitelisted
    }

    /* Les électeurs inscrits sont autorisés à enregistrer leurs propositions 
    pendant que la session d'enregistrement est active. */

    struct Proposal { string description; uint voteCount; }
    Proposal[] public proposals;
    event ProposalRegistered(uint proposalId);

    function _addProposal (string memory _description) external {
        require(state == WorkflowStatus.ProposalsRegistrationStarted,"Proposal can be addes only in Proposal Registration phase:1"); //Check que nous sommes bien dans la phase d'enregistrement des adresses
        require(_whitelistCount>0,"Whitelist must contain at least one address");
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

/* L'administrateur de vote met fin à la session d'enregistrement des propositions.

L'administrateur du vote commence la session de vote.

Les électeurs inscrits votent pour leur proposition préférée.

L'administrateur du vote met fin à la session de vote.

L'administrateur du vote comptabilise les votes.

Tout le monde peut vérifier les derniers détails de la proposition gagnante.
     */
}