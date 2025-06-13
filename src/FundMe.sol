//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConvertor } from './PriceConvertor.sol';

error FundMe__notOwner();

contract FundMe {

    using PriceConvertor for uint256;
    uint256 public constant MINIMUM_USD = 5e18; 
    address[] public funders;
    mapping(address => uint256) public accountSentMoney;
    address public immutable i_owner; 

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable { 
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enought eth");
        
        funders.push(msg.sender);
        accountSentMoney[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner(){
        for(uint256 i =0; i<funders.length; i++){
            address funderUser = funders[i];
            accountSentMoney[funderUser] = 0; 
        }
        funders = new address[](0);
        (bool callCheck, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(callCheck,"Call failed");
    }

    modifier onlyOwner(){
        if(msg.sender != i_owner){
            revert FundMe__notOwner(); 
        }
        _; 
    }

    receive() payable external{
        fund();
    }

    fallback() payable external{
        fund();
    }
}