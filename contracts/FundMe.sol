// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address => uint256) public addresstoValuePaid;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _price_feed) public {
        priceFeed = AggregatorV3Interface(_price_feed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimum = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimum,
            "You need to spend more ETH!"
        );
        addresstoValuePaid[msg.sender] += msg.value;
        funders.push(msg.sender);
        //what is Eth -> USD conversion rate is ?
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 _ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountToUSD = (ethPrice * _ethAmount) / 1000000000000000000;
        return ethAmountToUSD;
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**18; // 10USD is the minimum price
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addresstoValuePaid[funder] = 0;
        }
        funders = new address[](0);
    }
}
