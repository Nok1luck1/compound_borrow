const hre = require('hardhat');
const { ethers } = require(`hardhat`);
// const Token = '0x11464Dc907cA7c48FBE09b08dd4C969e349363D3'
//const SkyMoney1 = '0x5932E2bfE271563c7700d1cA941829c4ccB62B43'
const InterestRate = "0x9a7356a642941E55EaE8947D239D4D5bB537731d";

const Compound_borrow = "0xFcCc5FABeAA6A0f79732dc0f97702E4e269d323f";
const CTOKEN = "0xEf7999fF764e0De1b3137c14eB9444646c5a4AFF";
//const SkyMoney5 = "0xdAc4eCf4913b0E4bEf53dfcf2927b1192bDa4117";

async function main() {
    //  console.log(`Verify contract 1`);
    // res1 = await hre.run("verify:verify", {
    //     address: SkyMoney1,
    //     constructorArguments: [],
    //     optimizationFlag: true
    // })

      console.log(`Verify Compound_borrow`);
        res = await hre.run("verify:verify", {
        address: Compound_borrow,
        constructorArguments: ["0x20572e4c090f15667cF7378e16FaD2eA0e2f3EfF","0x3cBe63aAcF6A064D32072a630A3eab7545C54d78","0x65F19195e488B9C1A1Ac08ca115f197C992bC776"],
        optimizationFlag: true
    })
    console.log(res);

    // console.log(`Verify  InterestRate `);
    // res2 = await hre.run("verify:verify", {
    //     address: InterestRate,
    //     constructorArguments: ["20000000000000000","180000000000000000","4000000000000000000","800000000000000000","0x3f4F5d9971c265a7485540207023EA4B68Af6dc6"],
    //     optimizationFlag: true
    // })
    // console.log(res2);

    // console.log(`Verify CTOKEN `);
    // res3 = await hre.run("verify:verify", {
    //     address: CTOKEN,
    //     constructorArguments: [ ],
    //     optimizationFlag: true
    // })
    // console.log(res3);


    // console.log(`Verify  contract4`);
    // res4 = await hre.run("verify:verify", {
    //     address: SkyMoney5,
    //     constructorArguments: [SkyMoney2,
    //     SkyMoney3,
    //     SkyMoney4,
    //     "200000000000000000000000000",
    //     "cPEDRIL",
    //     "cPDR",
    //     8],
    //     optimizationFlag: true
    // })
    // console.log(res4);

  
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });