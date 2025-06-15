//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../src/FundMe.sol';
import {FundMeDeploy } from '../script/DeployFundMe.s.sol';
contract FundMeTest is Test{
    FundMe fundMe;
    address USER = makeAddr("User");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external{ // this function gets called first
        FundMeDeploy fundMeDeploy = new FundMeDeploy();
        fundMe = fundMeDeploy.run();
        vm.deal(USER,STARTING_VALUE);
    }

    function testMinDollarIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender()public view{
        address funderOwner = fundMe.getOwner();
        assertEq(funderOwner, msg.sender);
    }

    function testCheckVersion() public view{
        uint256 versionCheck = fundMe.versionCheck();
        assertEq(versionCheck , 4);
    }


    function testTestDemo()public view{
        uint256 numberChecker = fundMe.testDemo();
        assertEq(numberChecker ,9 );
    }

    function testFundMeToSendEthCallFail()public {
        vm.expectRevert(); // this means next line could revert
        fundMe.fund();
    }

    function testFundToSuccessUpdate()public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); //sening in this function 10eth
        uint256 amountFunded = fundMe.getAddressToAMountFunded(USER);
        assertEq(amountFunded , SEND_VALUE);
    }

    function testFundUserInArray()public funded{
        address funderAddress = fundMe.getFunderAddress(0);
        assertEq(funderAddress, USER);
    }

    function testOnlyOwnerCanWithDraw() funded public{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawTestWithSingleOwner() funded public{
        uint256 funderOwner = fundMe.getOwner().balance;
        
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
       
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;

        assertEq(endingFunderBalance ,0);
        assertEq(funderOwner+ startingFundMeBalance , endingOwnerBalance);

    }

    function testWithdrawWithMultipleFunders()public funded{
        uint160 numberOfFunders = 10;
        uint160 funderIndex =1;
        for(uint160 i = funderIndex;i < numberOfFunders; i++){
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        }

        uint256 funderOwner = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assert(address(fundMe).balance == 0);
        assert(funderOwner+startingFundMeBalance == fundMe.getOwner().balance);
    }

     modifier funded {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }

}


// main thing setup function gets called each and everytime before anytest function is excuted