// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Deploy mock on local anvil chain
// keep of tract of different address over different chains sepolia or mainnet any of those
import {Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/Mockv3Aggregator.sol';
contract HelperConfig is Script{
    
    uint8 public constant DECIMAL =8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetwrokConfig{
        address priceFeed;
    }

    constructor(){
        if(block.chainid == 11155111){
            activeNetwork = getSepoliaEthConfig();
        }else{
            activeNetwork = getAnvilPriceConfig();
        }
    }

    NetwrokConfig public activeNetwork;

    function getSepoliaEthConfig () public pure returns(NetwrokConfig memory){
        NetwrokConfig memory sepoliaConfig = NetwrokConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getAnvilPriceConfig () public returns(NetwrokConfig memory){
        if(activeNetwork.priceFeed != address(0)){
            return activeNetwork;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMAL, INITIAL_PRICE);
        vm.stopBroadcast();
        NetwrokConfig memory anvilConfig = NetwrokConfig({
            priceFeed : address(mockV3Aggregator)
        });
        return anvilConfig;
    }
}