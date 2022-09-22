//npx hardhat run scripts/deploy.js --network nameOfNetwork

const { ethers, upgrades } = require('hardhat')
const hre = require('hardhat');


//const USDT = '0xdAC17F958D2ee523a2206206994597C13D831ec7' mainnet
//const Owner ='0x3f4F5d9971c265a7485540207023EA4B68Af6dc6'
const main = async () => {
    async function verify(address, args) {
    if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
        let retry = 20;
        console.log("Sleeping before verification...");
        while ((await ethers.provider.getCode(address).catch(() => "")).length <= 3 && retry >= 0) {
            
            
            --retry;
        }
       

        console.log(address, args);

        await hre
            .run("verify:verify", {
                address,
                constructorArguments: args
            })
            // .catch(console.error);
            .catch(() => console.log("Verification failed"));
        // console.log("Verification is completed")
    }
}
  const [deployer] = await ethers.getSigners()
  console.log(`Deployer address: ${deployer.address}`)

  


//   const Comtroller123 = await ethers.getContractFactory("Comptroller");
//   const Comptroller777 = await Comtroller123.deploy();
//   await Comptroller777.deployed();

//   await verify(Comptroller777.address);
//   console.log(Comptroller777.address);

  
//   const InterestRateModel = await ethers.getContractFactory("JumpRateModelV2");
//   const InterestRate = await InterestRateModel.deploy("20000000000000000","180000000000000000","4000000000000000000","800000000000000000",deployer.address);
//   await InterestRate.deployed(); 
//   console.log("JUmpRateModelv2",InterestRate.address);

    // const Timelock = await ethers.getContractFactory("Timelock");
    // const timelock = await Timelock.deploy("0x3f4F5d9971c265a7485540207023EA4B68Af6dc6",172800);
    // await timelock.deployed();
    // console.log("timelock address",timelock.address);



 
    // const CErc20Delegate = await ethers.getContractFactory("CErc20");
    // const CErc20Delegate1 = await CErc20Delegate.deploy();
    // await CErc20Delegate1.deployed();
    // console.log("CERC20 delegate",CErc20Delegate1.address);


    
    // const CErc20Delegator = await ethers.getContractFactory("CErc20Delegator");
    // const CErc20Delegator1 = await CErc20Delegator.deploy("0x98D0De8E2FD4AA6901834BF9168bA1A937A7B5A4",
    // "0x626E8e147a49a070E11e75cAF0950dE04Fcefa70",
    // "0x9a7356a642941E55EaE8947D239D4D5bB537731d",
    // "200000000000000000000000000", "cPEDRIL","cPDR",8,
    // "0x3f4F5d9971c265a7485540207023EA4B68Af6dc6",
    // CErc20Delegate1.address,"0x0000000000000000000000000000000000000000");

    // await CErc20Delegator1.deployed();
    // console.log(CErc20Delegator1.address);



    const borrow = await hre.ethers.getContractFactory("Compound_borrow");
    const Borrow = await borrow.deploy("0x20572e4c090f15667cF7378e16FaD2eA0e2f3EfF","0x3cBe63aAcF6A064D32072a630A3eab7545C54d78","0x65F19195e488B9C1A1Ac08ca115f197C992bC776");
    await Borrow.deployed();
    await Borrow.createAssetForCtoken("0x208f73527727bcb2d9ca9ba047e3979559eb08cc","0x2073d38198511F5Ed8d893AB43A03bFDEae0b1A5");
    await Borrow.createAssetForToken("0x2073d38198511F5Ed8d893AB43A03bFDEae0b1A5","0x208f73527727bcb2d9ca9ba047e3979559eb08cc");
    console.log(`deployed to: ${Borrow.address}`)


    //   const MyTokn = await ethers.getContractFactory("MyToken");
//   const Token = await MyTokn.deploy();
//   await Token.deployed();

//   await verify(Token.address);
//   console.log(Token.address);

    // await verify(InterestRate.address);
    // await verify(CTOKEN.address);
    //await verify(Borrow.address);
}
    

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
