//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../src/FundMe.sol';
import {FundMeDeploy } from '../script/DeployFundMe.s.sol';
contract FundMeTest is Test{
    FundMe fundMe;

    function setUp() external{ // this function gets called first
        FundMeDeploy fundMeDeploy = new FundMeDeploy();
        fundMe = fundMeDeploy.run();
    }

    function testMinDollarIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender()public view{

        assertEq(fundMe.i_owner(), msg.sender);
    }


    function testTestDemo()public view{
        uint256 numberChecker = fundMe.testDemo();
        assertEq(numberChecker ,9 );
    }
}