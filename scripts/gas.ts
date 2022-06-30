
import { ethers, network } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";
import { emojiAssets } from "../assets/openemoji";
import { silhouettesAssets } from "../assets/silhouettes";
import { cryptoAssets } from "../assets/crypto";
import { deploy } from "../utils/deploy";
import { gasEstimate } from "../utils/math";

async function main() {
  const { assetStore, materialToken } = await deploy();
  console.log("assetStore", assetStore.address);
  console.log("materialToken", materialToken.address);

  const [owner] = await ethers.getSigners();
  const unitPrice = ethers.BigNumber.from(55);

  let promises = actionAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return await tx.wait();
  });
  const action = (await Promise.all(promises)).map(gasEstimate);

  promises = socialAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return await tx.wait();
  });
  const social = (await Promise.all(promises)).map(gasEstimate);

  promises = emojiAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return await tx.wait();
  });
  const emoji = (await Promise.all(promises)).map(gasEstimate);

  promises = silhouettesAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return await tx.wait();
  });
  const silhouettes = (await Promise.all(promises)).map(gasEstimate);

  promises = cryptoAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mintWithAsset(asset, 0);
    return await tx.wait();
  });
  const crypto = (await Promise.all(promises)).map(gasEstimate);

  console.log("const gas =", { action, social, emoji, silhouettes, crypto }, ";");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});