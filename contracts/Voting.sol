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
    event VoterRegistered(address voterAddress);

    function _whitelist(address _address) public onlyOwner{
        require(state == WorkflowStatus.RegisteringVoters,"Address can be added only in Registration phase"); //Check que nous sommes bien dans la phase d'enregistrement des adresses
        require(!whitelist[_address],"Address already registered");//Check si l'addresse n'est pas déjà dans la whitelist
        whitelist[_address]=true; //Ajoute l'addresse si elle n'est pas dans la liste

        emit VoterRegistered(_address); //emet sur la blockchain l'adresse whitelisted
    }
    
    
}