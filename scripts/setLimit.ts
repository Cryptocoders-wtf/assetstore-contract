import { ethers } from "hardhat";

async function main() {
  const contractAddress = "0xdb9Ae4A1CAE7D45f2601e8efeCDb07EF33635CC7";

  // We get the contract to deploy
  const factory = await ethers.getContractFactory("PrideSquiggle");
  const contract = factory.attach(contractAddress);

  await contract.setLimit(100);
  await contract.setDescription("Celebrating Pride Month 2022!");

  const data = await contract.limit();
  console.log(data);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});