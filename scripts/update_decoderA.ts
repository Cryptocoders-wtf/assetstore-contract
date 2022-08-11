import { ethers, network } from "hardhat";
import { storeAddress } from "../utils/storeAddress";

async function main() {
  const [owner] = await ethers.getSigners();
  console.log("network:", network.name);
  console.log("storeAddress:", storeAddress);

  const SVGFactory = await ethers.getContractFactory("SVGPathDecoderA");
  const decoder = await SVGFactory.deploy();
  await decoder.deployed();
  console.log(`      decoder="${decoder.address}"`);

  const storeFactory = await ethers.getContractFactory("AssetStore");
  const assetStore = storeFactory.attach(storeAddress);
  const tx = await assetStore.setPathDecoder(decoder.address);
  const result = await tx.wait();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});