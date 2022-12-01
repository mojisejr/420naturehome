import { ethers } from "hardhat";

async function main() {
  const [dev] = await ethers.getSigners();
  const tfac = ethers.getContractFactory("MyToken");
  const cfac = ethers.getContractFactory("PayWay420");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
