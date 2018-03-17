pragma solidity ^0.4.18;

import "./Owned.sol";
import "./StringUtils.sol";
import "./SafeMath.sol";
import {ERC20Interface} from "./FixedSupplyToken.sol";

contract Exchange is Owned {
	
	using SafeMath for uint;
	
	function Exchange(){
	
	}
	
	event TokenDeposit(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _time);
	event TokenWithdrawal(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _time);
	event EthDeposit(address indexed _from, uint _amount, uint _time);
	event EthWithdrawal(address indexed _from, uint _amount, uint _time);
	
	event LimitSellOrderCreated(uint indexed _symbolIndex, address _who, uint _amount, uint _priceInWei, uint _orederKey);
	event SellOrderFullfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orederKey);
	event SellOrderCancelled(uint indexed _symbolIndex, uint _priceInWei, uint _orederKey);
	
	event LimitBuyOrderCreated(uint indexed _symbolIndex, address _who, uint _amount, uint _priceInWei, uint _orederKey);
	event BuyOrderFullfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orederKey);
	event BuyOrderCancelled(uint indexed _symbolIndex, uint _priceInWei, uint _orederKey);
	
	event TokenAdded(uint _symbolIndex, string _token, uint _time);
	
	using StringUtils for string;
	
	struct Offer {
		
		uint amount;
		address who;
		
	}
	
	struct OrderBook {
		
		uint higherPrice;
		uint lowerPrice;
		mapping(uint => Offer) offers;
		uint offers_key;
		uint offers_length;
		
	}
	
	struct Token {
		
		address tokenContract;
		string symbolName;
		
		mapping(uint => OrderBook) buyBook;
		
		uint curBuyPrice;
		uint lowestBuyPrice;
		uint amountBuyPrices;
		
		mapping(uint => OrderBook) sellBook;
		
		uint curSellPrice;
		uint highestSellPrice;
		uint amountSellPrices;
		
	}
	
	mapping(uint8 => Token) tokens;
	uint8 symbolNameIndex;
	
	
	mapping(address => mapping(uint8 => uint)) tokenBalanceForAddress;
	mapping(address => uint)ethBalanceForAddress;
	
	
	function stringToBytes32(string memory source) returns (bytes32 result) {
		bytes memory tempEmptyStringTest = bytes(source);
		if (tempEmptyStringTest.length == 0) {
			return 0x0;
		}
		
		assembly {
			result := mload(add(source, 32))
		}
	}
	
	function buyToken(string symbolName, uint priceInWei, uint amount){
		uint8 tokenIndex = getSymbolIndex(symbolName);
		require(tokenIndex != 0);
		
		
		uint totalAmountEthRequired = amount.mul(priceInWei);
		require(totalAmountEthRequired > 0);
		
		ethBalanceForAddress[msg.sender] = ethBalanceForAddress[msg.sender].sub(totalAmountEthRequired);
		
		if (tokens[tokenIndex].amountSellPrices == 0 || tokens[tokenIndex].curSellPrice > priceInWei) {
			addBuyOffer(tokenIndex, priceInWei, amount, msg.sender);
			LimitBuyOrderCreated(tokenIndex, msg.sender, amount, priceInWei, tokens[tokenIndex].buyBook[priceInWei].offers_length);
			
		}
		else {
		
		
		}
		
	}
	
	
	function addBuyOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who)
	{
		if (tokens[tokenIndex].amountBuyPrices == 0) {
			tokens[tokenIndex].curBuyPrice = priceInWei;
			tokens[tokenIndex].lowestBuyPrice = priceInWei;
			tokens[tokenIndex].amountBuyPrices++;
			tokens[tokenIndex].buyBook[priceInWei].offers_key++;
			tokens[tokenIndex].buyBook[priceInWei].offers_length++;
			tokens[tokenIndex].buyBook[priceInWei].offers[tokens[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount, who);
		}
		else
		{
			
			uint price = tokens[tokenIndex].lowestBuyPrice;
			
			while (priceInWei < price && tokens[tokenIndex].buyBook[price].higherPrice != 0) {
				price = tokens[tokenIndex].buyBook[price].higherPrice;
			}
			
			if (price > priceInWei)
			{
			
			}
			else
			{
				if (priceInWei == price)
				{
					tokens[tokenIndex].buyBook[priceInWei].offers_length++;
					tokens[tokenIndex].buyBook[priceInWei].offers[tokens[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount, who);
				}
				else
				{
				
				
				}
			}
			
			
		}
		
	}
	
	function depositEither() payable {
		ethBalanceForAddress[msg.sender] = ethBalanceForAddress[msg.sender].add(msg.value);
		EthDeposit(msg.sender, msg.value, now);
	}
	
	function withdrawEither(uint amountInWei){
		ethBalanceForAddress[msg.sender] = ethBalanceForAddress[msg.sender].sub(amountInWei);
		msg.sender.transfer(amountInWei);
		EthWithdrawal(msg.sender, amountInWei, now);
	}
	
	function getEthBalanceInWei() constant returns (uint){
		return ethBalanceForAddress[msg.sender];
	}
	
	function depositToken(string symbolName, uint amount)
	{
		uint8 tokenIndex = getSymbolIndex(symbolName);
		require(tokenIndex != 0);
		uint newBalance = tokenBalanceForAddress[msg.sender][tokenIndex].add(amount);
		
		ERC20Interface token = ERC20Interface(tokens[tokenIndex].tokenContract);
		require(token.transferFrom(msg.sender, address(this), amount) == true);
		
		tokenBalanceForAddress[msg.sender][tokenIndex] = newBalance;
		TokenDeposit(msg.sender, tokenIndex, amount, now);
	}
	
	function withdrawToken(string symbolName, uint amount)
	{
		uint8 tokenIndex = getSymbolIndex(symbolName);
		require(tokenIndex != 0);
		uint newBalance = tokenBalanceForAddress[msg.sender][tokenIndex].sub(amount);
		
		ERC20Interface token = ERC20Interface(tokens[tokenIndex].tokenContract);
		require(token.transferFrom(address(this), msg.sender, amount));
		
		tokenBalanceForAddress[msg.sender][tokenIndex] = newBalance;
		TokenWithdrawal(msg.sender, tokenIndex, amount, now);
		
	}
	
	function getBalance(string symbolName) constant returns (uint)
	{
		uint8 tokenIndex = getSymbolIndex(symbolName);
		require(tokenIndex != 0);
		
		return tokenBalanceForAddress[msg.sender][tokenIndex];
	}
	
	
	function addToken(string symbolName, address erc20TokenAddress) onlyOwner {
		require(!hasToken(symbolName) && symbolNameIndex != 255 && bytes(symbolName).length <= 32);
		symbolNameIndex++;
		tokens[symbolNameIndex].symbolName = symbolName;
		tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
		TokenAdded(symbolNameIndex, symbolName, now);
	}
	
	function getTokens() constant returns (bytes32[]  names, address[] addresses){
		names = new bytes32[](symbolNameIndex);
		addresses = new address[](symbolNameIndex);
		
		for (uint8 i = 1; i <= symbolNameIndex; i++) {
			names[i - 1] = stringToBytes32(tokens[i].symbolName);
			addresses[i - 1] = tokens[i].tokenContract;
		}
		
		return (names, addresses);
	}
	
	function hasToken(string symbolName) returns (bool){
		return (getSymbolIndex(symbolName) != 0);
	}
	
	
	function getSymbolIndex(string symbolName)  returns (uint8){
		for (uint8 i = 1; i <= symbolNameIndex; i++) {
			if (tokens[i].symbolName.equal(symbolName)) {
				return i;
			}
		}
		return 0;
	}
	
}