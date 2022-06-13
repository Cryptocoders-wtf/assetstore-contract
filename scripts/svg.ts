
import { ethers, network } from "hardhat";

async function main() {
  const factory = await ethers.getContractFactory("VectorToken");
  const contract = await factory.deploy();
  await contract.deployed();
  const result = await contract.generateSVG(0);
  console.log(result);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});