
require('babel-polyfill')
var FixedSupplyToken = artifacts.require("FixedSupplyToken");
var Exchange = artifacts.require("Exchange");
var SafeMath = artifacts.require("SafeMath");
var StringUtils = artifacts.require("StringUtils");
var fs = require('fs');
var artifacts = artifacts;
var FixedSupplyTokenInst;

module.exports = async function(deployer , network , accounts) {
  await deployer.deploy(SafeMath);
  await deployer.deploy(StringUtils);
  await deployer.link(SafeMath, FixedSupplyToken);
  await  deployer.link(SafeMath,Exchange);
  await  deployer.link(StringUtils,Exchange);
  await deployer.deploy(FixedSupplyToken , "IRON" , "IRON COIN" , 18 , 1000000 , {from:accounts[1]}).then(async function(){
    return await deployer.deploy(Exchange , {from: accounts[0]});
    }).then(async function () {
    var exchangeInst = await Exchange.deployed();
    var fixedSupplyTokenInst = await  FixedSupplyToken.deployed();
      await exchangeInst.addToken(await fixedSupplyTokenInst.symbol({from:accounts[0]}), fixedSupplyTokenInst.address);
  })

  //deployer.new(FixedSupplyToken,["SIAM", "SIAM COIN" , 16 , 1000000 , {from:accounts[2]}]).then(function (instance) {
   //console.log(instance.address());
  //})



  /*FixedSupplyToken.new("SIAM", "SIAM COIN" , 16 , 1000000 , {from:accounts[2]}).then(function (instance) {
    fs.writeFile("tmp/contracts", instance.address , function(err) {
      if(err) {
        return console.log(err);
      }
      console.log("The file was saved!");
    });
    artifacts.save(instance, 'SiamToken');
  })*/





};
