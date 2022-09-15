const hre = require('hardhat');
const { ethers } = require(`hardhat`);
// const Token = '0x11464Dc907cA7c48FBE09b08dd4C969e349363D3'
const SkyMoney = '0xE66888A2fD6015E54754fa7020F6B729a589c698'

async function main() {
    // console.log(`Verify SkyMoney contract`);
    // res = await hre.run("verify:verify", {
    //     address: Token,
    //     constructorArguments: []
    //     ,
    //     optimizationFlag: true
    // })
    // console.log(res);


    console.log(`Verify SkyMoney contract`);
    res2 = await hre.run("verify:verify", {
        address: SkyMoney,
        constructorArguments: ["0x20572e4c090f15667cF7378e16FaD2eA0e2f3EfF"],
        optimizationFlag: true
    })
    console.log(res2);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });