import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";
import { writeFile } from "fs";

async function main() {
  const storeFactory = await ethers.getContractFactory("AssetStore");
  const assetStore = storeFactory.attach(storeAddress);

  const factory = await ethers.getContractFactory("DrawYourOwn");
  const tokenContract = await factory.deploy(storeAddress, storeAddress, developer, proxy);
  await tokenContract.deployed();
  console.log(`      tokenAddress="${tokenContract.address}"`);

  const tx9 = await assetStore.setWhitelistStatus(tokenContract.address, true);
  await tx9.wait();

  const composerAddress = await tokenContract.assetComposer();
  const composerFactory = await ethers.getContractFactory("AssetComposer");
  const composer = composerFactory.attach(composerAddress);

  const registryAddress = await composer.registry();
  const registryFactory = await ethers.getContractFactory("AssetProviderRegistry");
  const registry = registryFactory.attach(registryAddress);

  const count = await registry.providerCount();
  console.log(` providerCount=`, count.toNumber());
  const [info] = await registry.getProvider(0);
  const storeProviderFactory = await ethers.getContractFactory("AssetStoreProvider");
  const storeProvider = storeProviderFactory.attach(info.provider);
  const supply = await storeProvider.totalSupply();
  console.log(` providerInfo=`, info.key, info.name, info.provider, supply.toNumber());
  const [info1] = await registry.getProvider(1);
  console.log(` providerInfo=`, info1.key, info1.name, info1.provider);
  //const svgPart = await assetStoreProvider.generateSVGPart(0);
  //console.log(` svgPart=`, svgPart);
  

  const addresses = `export const token_addresses = {\n`
  + `  customTokenAddress:"${tokenContract.address}",\n`
  + `  composerAddress:"${composer.address},"\n`
  + `  registryAddress:"${registry.address}"\n`
  + `}\n`;
  await writeFile(`./cache/addresses_draw_${network.name}.ts`, addresses, ()=>{});
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});