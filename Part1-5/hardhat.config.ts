import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const ALCHEMY_API_KEY = "I3TZIvYkW57wS_Zzebd4BLd4qU7YX_mD";
const GOERLI_PRIVATEKEY =
  "cc8b52fb2d99daa1ee664ba9866732b39c450de05eaf3889943d784c432a651f";
const config: HardhatUserConfig = {
  solidity: "0.8.17",
};

module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `//eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATEKEY],
    },
  },
};
export default config;
