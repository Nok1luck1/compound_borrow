import { BigNumber } from "ethers";

const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

const main = async () => {
  const [deployer] = await ethers.getSigners();
  console.log(`Deployer address: ${deployer.address}`);
  //let nonce = await network.provider.send('eth_getTransactionCount', [deployer.address, 'latest']) - 1
  // const CTokenDelegator = await ethers.getContractFactory("CErc20Delegator");
  // const CTokenDelegate = await ethers.getContractFactory("CErc20Delegate");
  // const cTokenImmut = await ethers.getContractFactory("CErc20Immutable");
  //const USDCcont = await ethers.getContractFactory("USDC");
  const ComtrollerCON = await ethers.getContractFactory("Comptroller");
  const InterestCON = await ethers.getContractFactory(
    "WhitePaperInterestRateModel"
  );

  // const USDC = await USDCcont.deploy();
  // console.log(USDC.address, "Token address");
  const Comtroller = await ComtrollerCON.deploy();
  console.log("Comtroller address", Comtroller.address);
  const Interest = await InterestCON.deploy(2102400, "120000000000000000");
  console.log("Interest rate address", Interest.address);
  // const tokneDelegate = await CTokenDelegate.deploy();
  // console.log("Token delegate", tokneDelegate.address);
  // //   const CTokenContImmutable = await cTokenImmut.deploy(
  // //     USDC.address, //underlying asset
  // //     Comtroller.address, //coontroller
  // //     Interest.address, //INterest Rate
  // //     "200000000000000000000000000", //initialExcnahge Rate
  // //     "cUSDC", //name
  // //     "cUSDC", //symbol
  // //     8, //decimals
  // //     deployer.address
  // //   );
  // //   console.log("CTokenContImmutable address", CTokenContImmutable.address);

  // const CTokenDeleag = await CTokenDelegator.deploy(
  //   USDC.address, //underlying asset
  //   Comtroller.address, //comptroller
  //   Interest.address, //INterest Rate
  //   BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
  //   "cUSDC", //name
  //   "cUSDC", //symbol
  //   8, //decimals
  //   deployer.address, //admin address
  //   tokneDelegate.address, //implementation
  //   "0x" //become implementation data
  // );
  // console.log("cTOKEn delegator", CTokenDeleag.address);
};

// This pattern is recommended to be able to use async/await everywhere and properly handle errors
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
