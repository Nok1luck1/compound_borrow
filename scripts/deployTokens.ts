import { BigNumber } from "ethers";

const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

const main = async () => {
  const [deployer] = await ethers.getSigners();
  console.log(`Deployer address: ${deployer.address}`);
  const Comtrolleraddress = "0xC36c8B379918E765133Faa81EC0AD1D7796b1Ed3";
  const Interestaddress = "0xF445856102e426a379E0D0d854C3a6e85b8465Cd";
  //let nonce = await network.provider.send('eth_getTransactionCount', [deployer.address, 'latest']) - 1
  const CTokenDelegator = await ethers.getContractFactory("CErc20Delegator");
  const CTokenDelegate = await ethers.getContractFactory("CErc20Delegate");
  const AAVEcont = await ethers.getContractFactory("AAVE");
  const AAVE = await AAVEcont.deploy();
  console.log(`AAve addr ${AAVE.address}`);
  const BATcont = await ethers.getContractFactory("BAT");
  const BAT = await BATcont.deploy();
  console.log(`BAT addr ${BAT.address}`);
  const DAIcont = await ethers.getContractFactory("DAI");
  const DAI = await DAIcont.deploy();
  console.log(`DAI addr ${DAI.address}`);
  const FAIcont = await ethers.getContractFactory("FEI");
  const FAI = await FAIcont.deploy();
  console.log(`FAI addr ${FAI.address}`);
  const LINKcont = await ethers.getContractFactory("LINK");
  const LINK = await LINKcont.deploy();
  console.log(`LINK addr ${LINK.address}`);
  const MKRcont = await ethers.getContractFactory("MKR");
  const MKR = await MKRcont.deploy();
  console.log(`MKR addr ${MKR.address}`);
  const SUSHIcont = await ethers.getContractFactory("SUSHI");
  const SUSHI = await SUSHIcont.deploy();
  console.log(`SUSHI addr ${SUSHI.address}`);
  const TUSDcont = await ethers.getContractFactory("TUSD");
  const TUSD = await TUSDcont.deploy();
  console.log(`TUSD addr ${TUSD.address}`);
  const UNIcont = await ethers.getContractFactory("UNI");
  const UNI = await UNIcont.deploy();
  console.log(`UNI addr ${UNI.address}`);
  const USDCcont = await ethers.getContractFactory("USDC");
  const USDC = await USDCcont.deploy();
  console.log(`USDC addr ${USDC.address}`);
  const USDPcont = await ethers.getContractFactory("USDP");
  const USDP = await USDPcont.deploy();
  console.log(`USDP addr ${USDP.address}`);
  //////////////////////////////////////////////////
  //deploy CTOKEns
  const tokneDelegateAAVE = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateAAVE.address);
  const CTokenDeleagAAVE = await CTokenDelegator.deploy(
    AAVE.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cAAVE", //name
    "cAAVE", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateAAVE.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorAAVE", CTokenDeleagAAVE.address);
  /////
  const tokneDelegateBAT = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateBAT.address);
  const CTokenDeleagBAT = await CTokenDelegator.deploy(
    BAT.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cBAT", //name
    "cBAT", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateBAT.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorBAT", CTokenDeleagBAT.address);
  ////////
  const tokneDelegateDAI = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateDAI.address);
  const CTokenDeleagDAI = await CTokenDelegator.deploy(
    DAI.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cDAI", //name
    "cDAI", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateDAI.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorDAI", CTokenDeleagDAI.address);
  //////
  const tokneDelegateFAI = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateFAI.address);
  const CTokenDeleagFAI = await CTokenDelegator.deploy(
    FAI.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cFEI", //name
    "cFEI", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateDAI.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorFAI", CTokenDeleagFAI.address);
  /////////
  const tokneDelegateLINK = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateLINK.address);
  const CTokenDeleagLINK = await CTokenDelegator.deploy(
    LINK.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cLINK", //name
    "cLINK", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateLINK.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorLINK", CTokenDeleagLINK.address);
  ///////
  const tokneDelegateMKR = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateMKR.address);
  const CTokenDeleagMKR = await CTokenDelegator.deploy(
    MKR.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cMKR", //name
    "cMKR", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateMKR.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorMKR", CTokenDeleagMKR.address);
  ////////
  const tokneDelegateSUSHI = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateSUSHI.address);
  const CTokenDeleagSUSHI = await CTokenDelegator.deploy(
    SUSHI.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cSUSHI", //name
    "cSUSHI", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateSUSHI.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorSUSHI", CTokenDeleagSUSHI.address);
  ////////
  const tokneDelegateTUSD = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateTUSD.address);
  const CTokenDeleagTUSD = await CTokenDelegator.deploy(
    TUSD.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cTUSD", //name
    "cTUSD", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateTUSD.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorTUSD", CTokenDeleagTUSD.address);
  //////////
  const tokneDelegateUNI = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateUNI.address);
  const CTokenDeleagUNI = await CTokenDelegator.deploy(
    UNI.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cUNI", //name
    "cUNI", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateUNI.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorUNI", CTokenDeleagUNI.address);
  /////////
  const tokneDelegateUSDC = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateUSDC.address);
  const CTokenDeleagUSDC = await CTokenDelegator.deploy(
    USDC.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cUSDC", //name
    "cUSDC", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateUSDC.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorUSDC", CTokenDeleagUSDC.address);
  //////////////
  const tokneDelegateUSDP = await CTokenDelegate.deploy();
  console.log("Token delegate", tokneDelegateUSDP.address);
  const CTokenDeleagUSDP = await CTokenDelegator.deploy(
    USDP.address, //underlying asset
    Comtrolleraddress, //comptroller
    Interestaddress, //INterest Rate
    BigNumber.from("200000000000000000000000000"), //initialExcnahge Rate
    "cUSDP", //name
    "cUSDP", //symbol
    8, //decimals
    deployer.address, //admin address
    tokneDelegateUSDP.address, //implementation
    "0x" //become implementation data
  );
  console.log("cTOKEN delegatorUSDP", CTokenDeleagUSDP.address);
};

// This pattern is recommended to be able to use async/await everywhere and properly handle errors
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
