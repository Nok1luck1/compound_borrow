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
            await sleep(50);
            --retry;
        }
        //await sleep(30000);

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

  


  const Comtroller123 = await ethers.getContractFactory("Comptroller");
  const Comptroller777 = await Comtroller123.deploy();
  await Comptroller777.deployed();

  await verify(Comptroller777.address);
  console.log(Comptroller777.address);

  
  const InterestRateModel = await ethers.getContractFactory("BaseJumpRateModelV2");
  const InterestRate = await InterestRateModel.deploy("20000000000000000","180000000000000000","4000000000000000000","800000000000000000",deployer.address);
  await InterestRate.deployed();

  await verify(InterestRate.address);
  console.log(InterestRate.address);


  const MyTokn = await ethers.getContractFactory("MyToken");
  const Token = await MyTokn.deploy();
  await Token.deployed();

  await verify(Token.address);
  console.log(Token.address);


 
  const cToken = (await ethers.getContractFactory("CErc20")).connect(deployer);
    const initValue = [
        Token.address,
        Comptroller777.address,
        InterestRate.addresss,
        "200000000000000000000000000",
        "cPEDRIL",
        "cPDR",
        8
    ];
    const CTOKEN = await cToken.deploy();
    
    await verify(CTOKEN.address);
    console.log(CTOKEN.address);



    const borrow = await hre.ethers.getContractFactory("Compound_borrow");
    const Borrow = await borrow.deploy("0x20572e4c090f15667cF7378e16FaD2eA0e2f3EfF",Comptroller777.address,InterestRate.address);
    await Borrow.deployed();
    await Borrow.createAssetForCtoken(Token.address,CTOKEN.address);
    console.log(`deployed to: ${Borrow.address}`)
    await verify.Borrow;
}
    
///0xe4E81Fa6B16327D4B78CFEB83AAdE04bA7075165 token waht we will swap and deposit

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
