require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {},
    ganache: {
      url: "http://127.0.0.1:7545/", // Ganache RPC URL
      accounts: {
        mnemonic: "tail fun gasp keep ghost project alcohol knee forum struggle consider gravity",
      },
    },
  },
};
