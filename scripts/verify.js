const hre = require('hardhat');
const { ethers } = require(`hardhat`);
// const Token = '0x11464Dc907cA7c48FBE09b08dd4C969e349363D3'
//const SkyMoney1 = '0x5932E2bfE271563c7700d1cA941829c4ccB62B43'
const SkyMoney2 = "0x8237c8a1d1F1419B1C4f8F69b5cd26A065635de2";
const SkyMoney3 = "0x0325E0Dc880c3130893047dD9a8088109DDe3991";
const SkyMoney4 = "0xa266d3Eb29ebfD438abba4c30CEb136938d64E7a";
//const SkyMoney5 = "0xdAc4eCf4913b0E4bEf53dfcf2927b1192bDa4117";

async function main() {
    //  console.log(`Verify contract 1`);
    // res1 = await hre.run("verify:verify", {
    //     address: SkyMoney1,
    //     constructorArguments: [],
    //     optimizationFlag: true
    // })
    // console.log(res1);
      console.log(`Verify  contract5`);
        res5 = await hre.run("verify:verify", {
        address: SkyMoney2,
        constructorArguments: ["0x20572e4c090f15667cF7378e16FaD2eA0e2f3EfF"],
        optimizationFlag: true
    })
    console.log(res5);

    console.log(`Verify  contract2 `);
    res2 = await hre.run("verify:verify", {
        address: SkyMoney3,
        constructorArguments: ["20000000000000000","180000000000000000","4000000000000000000","800000000000000000","0x3f4F5d9971c265a7485540207023EA4B68Af6dc6"],
        optimizationFlag: true
    })
    console.log(res2);

    console.log(`Verify Scontract3 `);
    res3 = await hre.run("verify:verify", {
        address: SkyMoney4,
        constructorArguments: [],
        optimizationFlag: true
    })
    console.log(res3);


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