import { ethers } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";
import { emojiAssets } from "../assets/openemoji";
import { silhouettesAssets } from "../assets/silhouettes";
import { cryptoAssets } from "../assets/crypto";

async function main() {
  const contractAddress = "0xB385a93f48813796EA7EC1cA8387B591d69EDF32";

  // We get the contract to deploy
  const factory = await ethers.getContractFactory("MaterialToken");
  const materialToken = factory.attach(contractAddress);

  const [owner] = await ethers.getSigners();

  const asset = cryptoAssets[1];
  asset.soulbound = owner.address;
  const tx = await materialToken.mintWithAsset(asset, 0);
  const result = await tx.wait();
  console.log(result.gasUsed);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});