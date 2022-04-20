// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "src/Contract.sol";
import "/Users/brunofiletti/Desktop/VS Studio/BrunoFiletti/foundry/testdata/cheats/Cheats.sol";

contract ContractTest is DSTest {

    Contract public thecontract;
    address payable owner;
    uint public houseBalance;
    uint[] private numbersGenerated;
    mapping(address => uint) public balanceOf;
    Cheats public cheats = Cheats(HEVM_ADDRESS);

    fallback() external payable {}
    receive() external payable {}
    

    function setUp() public {
        thecontract = new Contract();
    }


    function testFailWithdrawn(uint amount) public {
        cheats.prank(address(0));
        thecontract.houseWithdrawn(amount);
    }

    function testHouseWithdrawn(uint32 _amount) public payable {
        thecontract.houseDeposit{value:_amount}();
        uint saveHouseBalance = thecontract.checkHouseBalance();
        thecontract.houseWithdrawn(_amount);
        assertEq(saveHouseBalance, houseBalance + _amount);
    } 

    function testFailHouseWithdrawn(uint _random) public {
        require(_random > 0);
        uint newValue = _random + houseBalance;
        thecontract.houseWithdrawn(newValue);
        
    } 

    function testPlayerDeposit(uint _random) public {
        uint balanceNow = thecontract.checkPlayerDeposit(msg.sender);
        cheats.prank(address(msg.sender));
        thecontract.playerDeposit{value: _random}();
        uint newBalance = thecontract.checkPlayerDeposit(msg.sender);
        assertEq(newBalance, balanceNow + _random);
    }

    function testPlayerWithdrawn(uint _random, uint _random2) public {
        cheats.assume(_random >= _random2);
        cheats.prank(address(msg.sender));
        thecontract.playerDeposit{value:_random}();
        uint balanceBeforeWithdraw = thecontract.checkPlayerDeposit(msg.sender);
        cheats.prank(address(msg.sender));
        thecontract.playerWithdrawn(_random2);
        uint newBalance = thecontract.checkPlayerDeposit(msg.sender);
        assertEq(newBalance, balanceBeforeWithdraw - _random2);
        
    }

    function testFailPlayJackpotWithoutTheMoney(uint _random, uint _random2) public {
        cheats.assume(_random2 > _random && _random2 > 0 && _random > 0 && _random < 900000000 && _random2 < 900000000000);
        address theOwner = thecontract.getTheOwner();
        cheats.prank(address(theOwner));
        thecontract.houseDeposit{value: _random * 1052631}();
        cheats.startPrank(msg.sender);
        thecontract.playerDeposit{value:_random2}();
        thecontract.jackpot(_random2);
        cheats.stopPrank();

    }
}
