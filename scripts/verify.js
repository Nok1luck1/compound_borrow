const hre = require('hardhat');
const { ethers } = require(`hardhat`);
// const Token = '0x11464Dc907cA7c48FBE09b08dd4C969e349363D3'
const SkyMoney = '0xfEB81D7b88f90aD7b22a4d1D4aE2Fe5BdED8888d'

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
        constructorArguments: [         
        ],
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