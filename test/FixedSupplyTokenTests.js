/**
 * Created by andrew on 18.27.1.
 */

var fixedSupplyToken =  artifacts.require('FixedSupplyToken');
var Exchange = artifacts.require('Exchange');
var fs = require('fs');
var Web3 = require('web3');
// create an instance of web3 using the HTTP provider.
// NOTE in mist web3 is already available, so check first if it's available before instantiating
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

contract('Exchange',function (accounts) {
  var _totalSupply;
  var tokenInstance;
  var  excIns;
  var siamToken;
  var ironToken;

  beforeEach('Create exchange contract', async function  () {
    excIns = await Exchange.new(accounts[0]);
    ironToken = await  fixedSupplyToken.new('IRON','IRON TOKEN',18 ,1000000 , {from: accounts[1]});
    siamToken = await  fixedSupplyToken.new('SIAM','SIAM TOKEN',16 ,1000000 , {from: accounts[2]});
  });

  it('Check if we can add token', async function () {
    var symbol = await ironToken.symbol();
    var address = ironToken.address;

    await excIns.addToken(symbol.toString() , address , {from:accounts[0]});

    var hasToken = await excIns.hasToken.call(symbol.toString() , {from:accounts[0]});
    assert.isTrue( hasToken , 'Has token ura');
  })

  it('Check if user can deposit tokens', async function () {
    var symbolIron = await ironToken.symbol();
    var addressIron = ironToken.address;

    await excIns.addToken(symbolIron.toString() , addressIron , {from:accounts[0]});

    var symbolSian = await siamToken.symbol();
    var addressSiam = siamToken.address;

    await excIns.addToken(symbolSian.toString(), addressIron , {from:accounts[0]})

    var tokens = await excIns.getTokens.call({from:accounts[0]}) ;

    fs.writeFile('tokens.txt', tokens[0] , (err) => {
      // throws an error, you could also catch it here
      if (err) throw err;

      // success case, the file was saved
      console.log('Lyric saved!');
    });

    await ironToken.approve(excIns.address,1000, {from:accounts[1]})
    await excIns.depositToken('IRON', 1000 , {from:accounts[1]});

    var balance = await excIns.getBalance.call('IRON',{from:accounts[1]});
    assert.equal( balance.toNumber() , 1000);
  });

  /*it('Check if owner amount of tokens equals to total supply',function () {

    return fixedSupplyToken.deployed().then(function (instance) {
      tokenInstance = instance;
      return tokenInstance.totalSupply.call()
    }).then(function (totalSupply) {
      _totalSupply = totalSupply
      return tokenInstance.balanceOf.call(accounts[0]);
    }).then(function (balanceOfOwner) {
      assert.equal(balanceOfOwner.toNumber(),_totalSupply.toNumber(),'Total amount of tokens belong to owner');
    });

  });*/

});