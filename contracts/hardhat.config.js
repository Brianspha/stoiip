require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
require("@openzeppelin/hardhat-upgrades");

require("dotenv").config();

module.exports = {
  defaultNetwork: "localhost",

  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    polygon: {
      url: `https://rpc-mumbai.maticvigil.com`,
      accounts: [process.env.PRIVATE_KEY],
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
    },
    localhost: {
      url: `http://127.0.0.1:8546`,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
        passphrase: "",
      },
      forking: {
        url: "https://ethereum-sepolia.blockpi.network/v1/rpc/public",
        blockNumber: 5398969
      }
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
