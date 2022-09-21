const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;

  const cryptoKaiTokenContract = await ethers.getContractFactory("CryptoKaiToken");
  const deployedCryptoKaiTokenContract = await cryptoKaiTokenContract.deploy(cryptoDevsNFTContract);

  console.log("Crypto Kai Token Contract Address: ", deployedCryptoKaiTokenContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })