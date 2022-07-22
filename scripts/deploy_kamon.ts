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

  const tx2 = await assetStore.setWhitelistStatus(kamonToken.address, true);
  await tx2.wait();

  const addresses = `export const kamon_addresses = {\n`
  + `  decoderAddress:"0xAa37fA6cEb855500E269513cA9e6E5F13B4D0D95",\n`
  + `  kamonAddress:"${kamonToken.address}"\n`
  + `}\n`;
  await writeFile(`./cache/addresses_kamon_${network.name}.ts`, addresses, ()=>{});
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});