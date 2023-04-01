const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BummyCore", () => {
  async function deployBummyCore() {
    const Signers = await ethers.getSigners();

    const BummyCoreContract = await ethers.getContractFactory("BummyCore");
    const BummyCore = await BummyCoreContract.deploy();

    return { BummyCore, Signers };
  }
});
