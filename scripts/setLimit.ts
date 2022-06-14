import { ethers } from "hardhat";

async function main() {
  const contractAddress = "0xaC644987601456554272B296936D3C262A7A1Fcf";

  // We get the contract to deploy
  const NounsToken = await ethers.getContractFactory("PrideSquiggle");
  const descriptorContract = NounsToken.attach(contractAddress);

  await descriptorContract.setLimit(2);

  const data = await descriptorContract.limit();
  console.log(data);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});