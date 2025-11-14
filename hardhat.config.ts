import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-foundry";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.26",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
      evmVersion: "cancun",
      viaIR: true,
    },
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      chainId: 56, // BSC
      forking: process.env.FORK_URL ? {
        url: process.env.FORK_URL,
      } : undefined,
    },
  },
  paths: {
    sources: "./src",
    tests: "./e2e",
    cache: "./cache",
    artifacts: "./artifacts",
    // Also include test mocks
  },
};

export default config;
