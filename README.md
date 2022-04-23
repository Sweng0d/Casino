# Galaxy Casino - Play and Have Fun!
![image](https://user-images.githubusercontent.com/101097089/163240320-0f3d47f9-d799-4c47-ab25-7aede6f9568d.png)

Welcome to Galaxy Casino!
The objective of this project is to create a casino on the Ethereum blockchain, where people can deposit their money, buy chips, and play the available games. Good luck!

# Managing user balance, constructors and modifiers
Here are the state variables needed to use the contract.
And some relevant events, the constructor and the modifier.



Basically we have a constructor that defines the address of the owner, which is the house of the Casino.
The house must always be analyzing how much money is in the casino, to ensure that the casino has no chance of going broke.
Remembering that the bankroll probability difference is not very big, being in most games around 5%.
Therefore, a few days of deficit are plausible.

After that, we have modifiers that help the games work and functions, which help to give information and are also present in the tests carried out at Foundry.

```
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
    
```

# Random Number Generator

Here we will use the keccak256 function with some variables. However, it is worth mentioning that this function is easily manipulated, it is recommended to use the VRF from Chainlink V2. We will use keccak only for demonstration and ease of testing. Especially since we are going to use fuzzing test, which involves thousands of random numbers, which makes the keccak function more effective for testing, later switching to Chainlink's VRF.

```
function randomNumber(uint maxNumber) public view returns(uint random) {
        random = uint(keccak256(abi.encodePacked
        (block.timestamp, block.difficulty, numbersGenerated.length, msg.sender))) % (maxNumber + 1);
    }
```

# Game Structure

Each game will have its own uniqueness.
Porém, antes de todo jogo, haverá algumas anotações, tais como:
-Probability of the player winning
-Probability reduced (we are the house, we need to make money)
-How much the player receives if he wins

# Game 01: Jackpot

Here is the most famous game in the casino. The famous jackpot

![image](https://user-images.githubusercontent.com/101097089/163922932-d8bbc22c-e24b-4c52-87dc-8f61221f8f86.png)

The idea of this game is: you will rotate 3 numbers from 0 to 999, if the 3 numbers are the same, you receive a big prize proportional to your bet

```
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
```

# Game 02: Heads or Tails

This game is a classic coin flip where you can double your money really fast, or lose it.

```
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
```

# Tests and Security

The tests were done in Foundry, and therefore written in Solidity.
Basically most of the tests we are fuzzing, trying to see if any number can cause a failure in the functioning of the Casino, and also testing the logic of our contract
You can check the test in Contract.t.sol


test
