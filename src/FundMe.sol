//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConvertor } from './PriceConvertor.sol';
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__notOwner();

contract FundMe {

    using PriceConvertor for uint256;
    uint256 public constant MINIMUM_USD = 5e18; 
    address[] public funders;
    mapping(address => uint256) public accountSentMoney;
    address public immutable i_owner; 
    AggregatorV3Interface private price_feed;

    constructor(address _priceFeed){
        i_owner = msg.sender;
        price_feed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable { 
        require(msg.value.getConversionRate(price_feed) >= MINIMUM_USD, "Didn't send enought eth");
        
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

    function testDemo()public pure returns(uint256){
        return 9;
    }

    function versionCheck() public view returns(uint256) {
        return price_feed.version();
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