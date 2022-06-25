
import { ethers, network } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";
import { deploy } from "../utils/deploy";
import { gasEstimate } from "../utils/math";

async function main() {
  const { assetStore, materialToken } = await deploy();
  const [owner] = await ethers.getSigners();
  const unitPrice = ethers.BigNumber.from(55);

  console.log("actionAssets");
  let promises = actionAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mint(asset, 0);
    return tx.wait();
  });
  let returns = await Promise.all(promises);
  console.log(returns.map(gasEstimate));

  console.log("socialAssets");
  promises = socialAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mint(asset, 0);
    return tx.wait();
  });
  returns = await Promise.all(promises);
  console.log(returns.map(gasEstimate));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});