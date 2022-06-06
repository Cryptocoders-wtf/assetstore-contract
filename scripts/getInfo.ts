import { ethers } from "hardhat";

async function main() {
  const contractAddress = process.env.NOUNSVILLE_ADDRESS as string;

  // We get the contract to deploy
  const factory = await ethers.getContractFactory("NounsvilleToken");
  const contract = factory.attach(contractAddress);
  const data = await contract.getPriceData();
  console.log(data);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
