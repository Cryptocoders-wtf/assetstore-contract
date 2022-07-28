import { ethers } from "hardhat";
import { addresses } from "../cache/addresses_localhost";

const encoder = new TextEncoder();

async function main() {
  // We get the contract to deploy
  const factory = await ethers.getContractFactory("CustomToken");
  const contract = factory.attach(addresses.tokenAddress);
  Object.keys(contract.functions).map((k)=>console.log(ethers.utils.keccak256(encoder.encode(k)).substring(0,10),  k));

  // https://docs.metamask.io/guide/registering-function-names.html
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
