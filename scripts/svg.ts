
import { ethers, network } from "hardhat";

async function main() {
  const factory = await ethers.getContractFactory("PrideSquiggle");
  const limit = 10000;
  const developer = "0x6a615Ca8D7053c0A0De2d11CACB6f321CA63BD62"; // sn2
  const proxy = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  const contract = await factory.deploy(limit, developer, proxy);
  await contract.deployed();
  const result = await contract.generateSVG(3);
  console.log(result);
  //console.log('data:image/svg+xml;base64,' + btoa(result));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});