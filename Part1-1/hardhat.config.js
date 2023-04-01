require("@nomicfoundation/hardhat-toolbox");
const ALCHEMY_API_KEY = "twNNZOKqiK9Cr6kaPqPr-Yxqv1rFY4t_";
const GOERLI_PRIVATEKEY = "cc8b52fb2d99daa1ee664ba9866732b39c450de05eaf3889943d784c432a651f"
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks:{
    goerli:{
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATEKEY],
    }
  }
};
