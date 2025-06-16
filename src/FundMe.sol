//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConvertor } from './PriceConvertor.sol';
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__notOwner();

contract FundMe {

    using PriceConvertor for uint256;
    uint256 public constant MINIMUM_USD = 5e18; 
    address[] private s_funders;
    mapping(address => uint256) private s_accountSentMoney;
    address private immutable i_owner; 
    AggregatorV3Interface private price_feed;

    constructor(address _priceFeed){
        i_owner = msg.sender;
        price_feed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable { 
        require(msg.value.getConversionRate(price_feed) >= MINIMUM_USD, "Didn't send enought eth");
        
        s_funders.push(msg.sender);
        s_accountSentMoney[msg.sender] += msg.value;
    }

    function cheapWithdraw() public onlyOwner{
        uint256 funderLength = s_funders.length;
        for(uint256 i =0; i<funderLength; i++){
            address funderUser = s_funders[i];
            s_accountSentMoney[funderUser] = 0; 
        }
        s_funders = new address[](0);
        s_funders = new address[](0);
        (bool callCheck, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(callCheck,"Call failed");

    }

    function withdraw() public onlyOwner(){
        for(uint256 i =0; i<s_funders.length; i++){
            address funderUser = s_funders[i];
            s_accountSentMoney[funderUser] = 0; 
        }
        s_funders = new address[](0);
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

    function getAddressToAMountFunded(address fundingAddress) external view returns(uint256){
        return s_accountSentMoney[fundingAddress];
    }

    function getFunderAddress(uint256 index)external view returns(address){
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return i_owner;
    }
}