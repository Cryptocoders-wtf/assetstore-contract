import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";
import { writeFile } from "fs";

async function main() {
  const storeFactory = await ethers.getContractFactory("AssetStore");
  const assetStore = storeFactory.attach(storeAddress);

  const assestStoreProviderFactory = await ethers.getContractFactory("AssetStoreProvider");
  const assetStoreProvider = await assestStoreProviderFactory.deploy(storeAddress);
  await assetStoreProvider.deployed();
  console.log(`      assetStoreProvider="${assetStoreProvider.address}"`);

  const composerFactory = await ethers.getContractFactory("AssetComposer");
  const composer = await composerFactory.deploy(storeAddress);
  await composer.deployed();
  console.log(`      composer="${composer.address}"`);

  const tx1 = await composer.registerProvider({name:"asset", provider: assetStoreProvider.address});
  await tx1.wait();

  const count = await composer.providerCount();
  console.log(` providerCount=`, count.toNumber());
  const info = await composer.getProvider(0);
  console.log(` providerInfo=`, info.name, info.provider);
  //const svgPart = await assetStoreProvider.generateSVGPart(0);
  //console.log(` svgPart=`, svgPart);
  
  const factory = await ethers.getContractFactory("DrawYourOwn");
  const tokenContract = await factory.deploy(storeAddress, storeAddress, developer, proxy, composer.address);
  await tokenContract.deployed();
  console.log(`      tokenAddress="${tokenContract.address}"`);

  const tx2 = await assetStore.setWhitelistStatus(tokenContract.address, true);
  await tx2.wait();

  const addresses = `export const token_addresses = {\n`
  + `  customTokenAddress:"${tokenContract.address}",\n`
  + `  composerAddress:"${composer.address}"\n`
  + `}\n`;
  await writeFile(`./cache/addresses_draw_${network.name}.ts`, addresses, ()=>{});
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});