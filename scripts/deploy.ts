import { ethers, network } from "hardhat";
import { deploy } from "../utils/deploy";
import { actionAssets, socialAssets } from "../assets/materials";

async function main() {
  const [owner] = await ethers.getSigners();
  const { assetStore, materialToken } = await deploy();
  console.log("network:", network.name);
  console.log(`      storeAddress="${assetStore.address}"`);
  console.log(`      tokenAddress="${materialToken.address}"`);

  const asset = socialAssets[5];
  asset.soulbound = owner.address;
  const tx = await materialToken.mintWithAsset(asset, 0);
  const result = await tx.wait();
  //const summary = result.events.map((event:any) => { return event.event });

  //console.log(summary);
  console.log("gasUsed:", result.gasUsed.toNumber());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});