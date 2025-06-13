//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from './helperConfig.s.sol';

contract FundMeDeploy is Script{
    function run() external returns(FundMe){
        HelperConfig helperConfig = new HelperConfig();
        address ethPriceFeed = helperConfig.activeNetwork();
        vm.startBroadcast();

        FundMe fundMe = new FundMe(ethPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}