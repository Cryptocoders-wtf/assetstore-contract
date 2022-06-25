
import { ethers, network } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";
import { deploy } from "../utils/deploy";

async function main() {
  const { assetStore, materialToken } = await deploy();
  const [owner] = await ethers.getSigners();
  const unitPrice = ethers.BigNumber.from(55);

  console.log("actionAssets");
  let promises = actionAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mint(asset, 0);
    return await tx.wait();
  });
  let returns = await Promise.all(promises);
  console.log(returns.map(t3 => { 
    const gasUsed = t3.gasUsed;
    const gasPrice = t3.effectiveGasPrice;
    const gasCost = gasUsed.mul(gasPrice);
    const gasCostEth = Number.parseFloat(ethers.utils.formatEther(gasCost));
    const ETHUSD = 1000; // assume eth is $1000 usd
    const gasCostUsd = gasCostEth * ETHUSD;
    return { ETH: gasCostEth, USD: gasCostUsd };    
  }));
/*
  console.log("socialAssets");
  promises = socialAssets.map(async (asset) => {
    asset.soulbound = owner.address;
    const tx = await materialToken.mint(asset, 0);
    const result = await tx.wait();
    return result.gasUsed.toNumber();
  });
  returns = await Promise.all(promises);
  console.log(returns);
*/
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});