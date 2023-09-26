const API_URL = process.env.API_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const ethers = require('ethers');
const fs = require('fs');
const contract = require("../artifacts/contracts/UniswapV3Twap.sol/UniswapV3Twap.json");

// provider - Alchemy
const alchemyProvider = new ethers.providers.JsonRpcProvider(API_URL);

// signer - you
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// contract instance
const oracleContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);

async function main() {
    console.log("contract address: " + CONTRACT_ADDRESS);
    const len = await oracleContract.getOracle(10);
    let csv = len.map((item) => {
        return item.join(",");
    }).join("\n");
    csv = "time,price\n" + csv;
    fs.writeFileSync('out.csv', csv, (err) => {
        if (err) throw err;
    });
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });