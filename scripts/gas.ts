
import { ethers, network } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";
import { deploy } from "../utils/deploy";

async function main() {
  const { assetStore, materialToken } = await deploy();
  const [owner] = await ethers.getSigners();

  console.log("actionAssets");
  let promises = actionAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mint(asset, 0);
    const result = await tx.wait();
    return result.gasUsed.toNumber();
  });
  let returns = await Promise.all(promises);
  console.log(returns);

  console.log("socialAssets");
  promises = socialAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mint(asset, 0);
    const result = await tx.wait();
    return result.gasUsed.toNumber();
  });
  returns = await Promise.all(promises);
  console.log(returns);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});