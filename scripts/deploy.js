// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners()
  console.log(`Deployer address: ${deployer.address}`)

  const borrow = await hre.ethers.getContractFactory("Compound_borrow");
  const Borrow = await borrow.deploy();
  await Borrow.deployed();
  await Borrow.addCtokenReplesentedByToken("0xe4E81Fa6B16327D4B78CFEB83AAdE04bA7075165","0xA253295eC2157B8b69C44b2cb35360016DAa25b1");
  console.log(`deployed to: ${Borrow.address}`)
}

///0xe4E81Fa6B16327D4B78CFEB83AAdE04bA7075165 token waht we will swap and deposit

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
