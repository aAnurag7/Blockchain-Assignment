require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks:{
    sepolia:{
      accounts:[`0x${process.env.PRIVATE_KEY}`],
      url: process.env.SEPOLIA_URL,
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
   }
};
