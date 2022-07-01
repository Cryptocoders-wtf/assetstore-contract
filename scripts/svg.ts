
import { SSL_OP_EPHEMERAL_RSA } from "constants";
import { ethers, network } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";
import { deploy } from "../utils/deploy";

async function main() {
  const { assetStore, materialToken } = await deploy();
  const [owner] = await ethers.getSigners();

  const asset = socialAssets[5];
  asset.soulbound = owner.address;
  const tx = await materialToken.mintWithAsset(asset, 0);
  await tx.wait();

  const uri = await materialToken.tokenURI(0);
  const data = atob(uri.substring(29));
  const json = JSON.parse(data);
  const imageData = json.image.substring(26);
  console.log(atob(imageData));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});