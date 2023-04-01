import { ethers } from "hardhat";
import {
  BummyCore,
  BummyCore__factory,
  BummyInfo,
  BummyInfo__factory,
} from "../typechain-types";

async function main() {
  const [deployer, owner] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const BummyCore: BummyCore__factory = await ethers.getContractFactory(
    "BummyCore"
  );
  const bummyCoreNFT: BummyCore = await BummyCore.deploy();

  console.log("NFT address:", bummyCoreNFT.address);
  console.log("Account Balance:", (await deployer.getBalance()).toString());

  const BummyInfo: BummyInfo__factory = await ethers.getContractFactory(
    "BummyInfo"
  );
  const bummyInfo: BummyInfo = await BummyInfo.deploy(bummyCoreNFT.address); //(address _privilegedBirtherAddress, address _bummyCoreAddress)

  console.log("bummyInfo:", bummyInfo.address);

  await bummyCoreNFT.setBummyInfoAddress(bummyInfo.address);
  const bummyId1 = await bummyCoreNFT.createPromoBummy(1, deployer.address);
  console.log("bummyId 1:", bummyId1);
  console.log(
    "bummyId 2:",
    await bummyCoreNFT.createPromoBummy(2, deployer.address)
  );
  console.log(
    "bummyId 3:",
    await bummyCoreNFT.createPromoBummy(3, deployer.address)
  );

  await bummyCoreNFT.createFirstGen0Bummy();
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
