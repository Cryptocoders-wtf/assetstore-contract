import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";
import { writeFile } from "fs";

async function main() {
  const [owner] = await ethers.getSigners();
  console.log("network:", network.name);
  console.log("storeAddress:", storeAddress);

  const SVGFactory = await ethers.getContractFactory("SVGPathDecoder2");
  const decoder = await SVGFactory.deploy();
  await decoder.deployed();
  console.log(`      decoder="${decoder.address}"`);

  const storeFactory = await ethers.getContractFactory("AssetStore");
  const assetStore = storeFactory.attach(storeAddress);
  const tx = await assetStore.setPathDecoder(decoder.address);
  const result = await tx.wait();

  const factory = await ethers.getContractFactory("KamonToken");
  const kamonToken = await factory.deploy(storeAddress, storeAddress, developer, proxy);
  await kamonToken.deployed();
  console.log(`      kamonToken="${kamonToken.address}"`);

  const addresses = `export const kamon_addresses = {\n`
  + `  decoderAddress:"${decoder.address}",\n`
  + `  kamonAddress:"${kamonToken.address}"\n`
  + `}\n`;
  await writeFile(`./cache/addresses_kamon_${network.name}.ts`, addresses, ()=>{});

  /*
  if (setWhitelist) {
    const tx = await assetStore.setWhitelistStatus(materialToken.address, true);
    await tx.wait();
  }
  */
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});