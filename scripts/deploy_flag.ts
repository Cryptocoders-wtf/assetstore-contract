import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";
import { writeFile } from "fs";

async function main() {
  const storeFactory = await ethers.getContractFactory("AssetStore");
  const assetStore = storeFactory.attach(storeAddress);

  const factory = await ethers.getContractFactory("EmojiFlagToken");
  const tokenContract = await factory.deploy(storeAddress, storeAddress, developer, proxy);
  await tokenContract.deployed();
  console.log(`      tokenAddress="${tokenContract.address}"`);

  const tx2 = await assetStore.setWhitelistStatus(tokenContract.address, true);
  await tx2.wait();

  const addresses = `export const token_addresses = {\n`
  + `  emojiFlagAddress:"${tokenContract.address}"\n`
  + `}\n`;
  await writeFile(`./cache/addresses_flag_${network.name}.ts`, addresses, ()=>{});
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});