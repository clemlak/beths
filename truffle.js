require('dotenv').config();
const HDWalletProvider = require('truffle-hdwallet-provider');

const ropstenUrl = `https://ropsten.infura.io/${process.env.INFURA}`;
const mainnetUrl = `https://mainnet.infura.io/${process.env.INFURA}`;

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*',
      gas: 3000000,
      gasPrice: 2000000000,
    },
    ropsten: {
      provider() {
        return new HDWalletProvider(process.env.MNEMONIC, ropstenUrl, 0);
      },
      network_id: 3,
      gas: 3000000,
      gasPrice: 2000000000,
    },
    live: {
      provider() {
        return new HDWalletProvider(process.env.MNEMONIC, mainnetUrl, 0);
      },
      network_id: 1,
      gasPrice: 2000000000,
      gas: 3000000,
    },
  },
  mocha: {
    useColors: true,
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
};
