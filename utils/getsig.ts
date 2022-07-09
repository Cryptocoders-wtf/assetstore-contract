import { ethers } from "hardhat";
import { addresses } from "../cache/addresses_localhost";

async function main() {
  // We get the contract to deploy
  const factory = await ethers.getContractFactory("MaterialToken");
  const contract = factory.attach(addresses.tokenAddress);
  Object.keys(contract.functions).map((k)=>console.log(k));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
