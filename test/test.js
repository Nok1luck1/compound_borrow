const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const Compound = require('@compound-finance/compound-js');
//const providerUrl = require('./config.js').httpProviderUrl;


describe("Compound contract", function () {
  it("Deployment should deploy Compound_borrow", async function () {
    const [owner] = await ethers.getSigners();
    //create priceOracle
    const PriceOracle = Compound.util.getAddress(Compound.PriceFeed);
    console.log("Price oracle",PriceOracle);
    //create Comtroller
    const comtrplller = await ethers.getContractFactory("Comptroller");
    const Comtrooller = await comtrplller.deploy();
    console.log("Comtroller",Comtrooller.address);
    //check oracle address
    const Oracle = await Comtrooller.oracle();
    console.log("ORCALE",Oracle);
  
    //create cUSDT
    const cUSD = Compound.util.getAddress(Compound.cUSDT);
    console.log("cUSD",cUSD);
    //read state from compound cUSDC
    const srpbOfcUSD = await Compound.eth.read(
    cUSD,
    'function supplyRatePerBlock() returns (uint256)',
  );
    console.log('cUSD market supply rate per block:', srpbOfcUSD.toString());
    ///read address underlying token
    const cUSDunder = Compound.eth.read(cUSD,'function underlying()returns (address)');
    console.log("cUSd address underlying",cUSDunder.address);
      
    const cETh = Compound.util.getAddress(Compound.cETH);
    console.log("cETh address",cETh);
    //create instanse of Compound_borrow contract  
    const CMPB = await ethers.getContractFactory("Compound_borrow");
    const Compound_borrow = await CMPB.deploy(cETh,Comtrooller.address,PriceOracle);
    console.log(Compound_borrow.address);

    const Token = await ethers.getContractFactory("MyToken");
    const token =  await Token.deploy();
    await token.mint(owner.address,1000000000000)
    //const addressPO = Compound_borrow.priceFeed();  
    
    expect(await Compound_borrow.comptroller()).to.equal(Comtrooller.address);
    //expect(await Compound_borrow.priceFeed()).to.equal(PriceOracle.address);
    //expect(await addressPO.toLowerCase()).to.equal(PriceOracle);
    await token.approve(Compound_borrow.address,1000000000000);
    console.log("approved");
    await Compound_borrow.createAssetForCtoken(token.address,cUSD);
    console.log("Asset created");
    const Xuplid =  await Compound_borrow.supplyERC20ToCompound(token.address,1000000000000);
    //expect().to.equal(10,10,10);
    console.log(Xuplid);
  
  //console.log("Supply createed",TransactionResult);
  });
});
 