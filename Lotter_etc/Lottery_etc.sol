// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract LotteryETC{
    address public manager;
    address payable[]  public participants;

    constructor(){
        manager = msg.sender;
    }

    receive() external payable{
        require(msg.value == 2 ether, "Please pay the exact fees, i.e 2ether");
        require(msg.sender != manager, "Manager are not allowed");
        participants.push(payable(msg.sender));
    }

    function getContractBalance() view public returns(uint){
        require(msg.sender == manager, "You are not authorized");
        return address(this).balance;
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    function selectWinner() public{
        require(msg.sender == manager, "You are not authorized");
        require(participants.length >=3, "Atleast 3 participants are required to initiate the process");
        uint r = random();
        address payable winner;
        uint index = r%participants.length;
        winner = participants[index];
        winner.transfer(getContractBalance());
        participants = new address payable[](0);
    }
}