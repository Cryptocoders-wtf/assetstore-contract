
import { ethers, network } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";
import { enojiAssets } from "../assets/openemoji";
import { silhouettesAssets } from "../assets/silhouettes";
import { deploy } from "../utils/deploy";
import { gasEstimate } from "../utils/math";

async function main() {
  const { assetStore, materialToken } = await deploy();
  const [owner] = await ethers.getSigners();
  const unitPrice = ethers.BigNumber.from(55);

  let promises = actionAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return tx.wait();
  });
  const action = (await Promise.all(promises)).map(gasEstimate);

  promises = socialAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return tx.wait();
  });
  const social = (await Promise.all(promises)).map(gasEstimate);

  promises = enojiAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return tx.wait();
  });
  const emoji = (await Promise.all(promises)).map(gasEstimate);

  promises = silhouettesAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return tx.wait();
  });
  const silhouettes = (await Promise.all(promises)).map(gasEstimate);


  console.log("const gas =", { action, social, emoji, silhouettes }, ";");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});