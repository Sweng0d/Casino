// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface Details {
    
}

contract Contract {

    address payable owner;
    uint public houseBalance;
    uint[] private numbersGenerated;
    mapping(address => uint) public balanceOf;

    event bigVictory(address who, uint howMuch);

    constructor() payable {
        owner = payable(msg.sender);
        houseBalance += msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier playerHasTheMoney(uint _bet) {
        require(balanceOf[msg.sender] >= _bet);
        _;
    }

    function getTheOwner() public view returns(address){
        return owner;
    }

    function houseDeposit() public payable onlyOwner {
        houseBalance += msg.value;
    }

    function houseWithdrawn(uint _amount) public payable onlyOwner {
        require(houseBalance >= _amount, "The house does not have this amount.");
        houseBalance -= _amount;
        (bool success, ) = msg.sender.call{value:_amount}("");
        require(success, "call failed"); //is it necessary? (this line)
    }

    function checkHouseBalance() public view returns(uint){
        uint _houseBalance = houseBalance; 
        return _houseBalance;
    }

    function playerDeposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }

    function playerWithdrawn(uint _amount) public payable {
        require(_amount <= balanceOf[msg.sender]);
        balanceOf[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value:_amount}("");
        require(success, "withdrawn failed!");
    }

    function checkPlayerDeposit(address _address) public view returns(uint) {
        return balanceOf[_address];
    }

    function randomNumber(uint maxNumber) public view returns(uint random) {
        random = uint(keccak256(abi.encodePacked
        (block.timestamp, block.difficulty, numbersGenerated.length, msg.sender))) % (maxNumber + 1);
    }
    
    //probability of win: 1/1000ˆ2 = 0.000001
    //probability reduced: 5% of reduction, so, the prob is now = 0.00000095
    //premium: 1052631x the money
    function jackpot(uint bet) public playerHasTheMoney(bet) returns (string memory result){
        require(bet > 0, "You cannot bet 0");
        require(houseBalance >= bet * 1052631, "The house does not have this money if you win."); //insolvency test
        balanceOf[msg.sender] -= bet;
        uint firstNumber = randomNumber(999);
        numbersGenerated.push(firstNumber);
        uint secondNumber = randomNumber(999);
        numbersGenerated.push(secondNumber);
        uint thirdNumber = randomNumber(999);
        numbersGenerated.push(thirdNumber);
        if(firstNumber != secondNumber || secondNumber != thirdNumber){
            houseBalance += bet;
            result = "You lost!";
        } else {
            houseBalance -= (bet * 1052631);
            balanceOf[msg.sender] += (bet * 1052631);
            result = "YOU WON!";
            emit bigVictory(msg.sender, bet * 1052631);
        }

    }

    //probability of win: 50%
    //probability reduced: 47%
    //premium: 
    function coinFlip(uint bet, bool head) public playerHasTheMoney(bet) returns (string memory result) {
        require(bet > 0, "You cannot bet 0");
        require(houseBalance>= bet * 2);
        balanceOf[msg.sender] -= bet;
        uint theAnswer = randomNumber(100);
        bool headAnswer;
        if (theAnswer < 47 && head == true) {
            headAnswer = true;
        } else if (theAnswer > 51 && head == false) {
            headAnswer = false;
        } else {
            headAnswer = !head;
        }
        if (head == headAnswer) {
            result = "You won!";
            balanceOf[msg.sender] += (bet * 2);
        } else {
            result = "You lost!";
            houseBalance += bet;
        }


    }

    //probability of win: 99%
    //probability reduced: 98%
    //premium: 1,005%
    function 99percent (uint _bet, uint _number) public  playerHasTheMoney(_bet) returns (string memory result) {
        require (_number > 0, _number <101);
        require (houseBalance >= _bet * 1,005);
        balanceOf[msg.sender] -= _bet;
        uint theAnswer = randomNumber(100);
        if (theAnswer == _number) {
            balanceOf[msg.sender] += (_bet * 1,005);
            houseBalance -= (_bet * 1,005);
        } else {
            houseBalance += _bet;
        }
    }
    






}