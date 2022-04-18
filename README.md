# Galaxy Casino - Play and Have Fun!
![image](https://user-images.githubusercontent.com/101097089/163240320-0f3d47f9-d799-4c47-ab25-7aede6f9568d.png)

Welcome to Galaxy Casino!
The objective of this project is to create a casino on the Ethereum blockchain, where people can deposit their money, buy chips, and play the available games. Good luck!

# Managing user balance, constructors and modifiers
## Here are the state variables needed to use the contract.
## And some relevant events, the constructor and the modifier.



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

# Managing user balance, constructors and modifiers

Here
