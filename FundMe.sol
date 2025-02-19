// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { PriceConvertor } from "./PriceConvertor.sol";

contract FundMe {
    using PriceConvertor for uint256;

    AggregatorV3Interface internal dataFeed;

    uint256 public minimumUSD = 5e18;
    address [] public funders;
    mapping (address funder => uint amountFunded) public addressToAmountFunded;

    address public owner;

    constructor () {
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
    }

    function fund() public payable {
        require( msg.value.getConversionRate() >= minimumUSD, "Didn't sent enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value.getConversionRate();
    }

    function withdraw() public onlyOwner {

        // require(msg.sender == owner, "Must be owner");
        for(uint funderIndex=0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // //transfer
        // payable (msg.sender).transfer( address(this).balance );

        // //send
        // bool sendSuccess = payable (msg.sender).send( address(this).balance );
        // require(sendSuccess, "Send Failed");

        //call
        (bool callSuccess, ) = payable (msg.sender).call{ value: address(this).balance }("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not the owner!");
        _;
    }

}
