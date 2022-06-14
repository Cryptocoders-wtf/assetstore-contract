// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, network } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const isRinkeby = network.name == "rinkeby";
  console.log("deploying...", network.name, isRinkeby ? "testnet": "*", process.env.ALCHEMY_API_KEY);
  
  const limit = 10000;
  const proxy = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  const developer = "0x6a615Ca8D7053c0A0De2d11CACB6f321CA63BD62"; // sn2

  // We get the contract to deploy
  const factory = await ethers.getContractFactory("PrideSquiggle");
  const contract = await factory.deploy(limit, developer, proxy);

  await contract.deployed();
  
  console.log("VectorToken deployed to:", contract.address);
  process.exit()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});