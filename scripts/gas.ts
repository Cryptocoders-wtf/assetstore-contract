
import { ethers, network } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";
import { deploy } from "../utils/deploy";

async function main() {
  const { assetStore, materialToken } = await deploy();
  const [owner] = await ethers.getSigners();

  const asset = actionAssets[0];
  asset.soulbound = owner.address;
  const tx = await materialToken.mint(asset, 0);
  const result = await tx.wait();
  console.log(result.gasUsed.toNumber());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});