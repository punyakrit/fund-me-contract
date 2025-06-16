// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../../src/FundMe.sol';
import {FundMeDeploy } from '../../script/DeployFundMe.s.sol';
import {FundFundMe,WithDrawMe} from '../../script/Interaction.s.sol';

contract FundMeTestIntegrations is Test{
    FundMe fundMe;
    address USER = makeAddr("User");
    uint256 constant STARTING_VALUE = 1 ether;


    function setUp()external{
        FundMeDeploy fundMeDeploy = new FundMeDeploy();
        fundMe = fundMeDeploy.run();
        vm.deal(USER,STARTING_VALUE);
    }

    function testUserCanCreateFund()public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithDrawMe withDrawMe = new WithDrawMe();
        withDrawMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }

}