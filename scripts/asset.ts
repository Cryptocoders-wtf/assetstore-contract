
import { SSL_OP_EPHEMERAL_RSA } from "constants";
import { ethers, network } from "hardhat";
import { actionAssets, socialAssets } from "../data/materials";
import { deploy } from "../utils/deploy";

async function main() {
  const { assetStore, materialToken } = await deploy();

  let promises:Array<Promise<any>> = actionAssets.map(asset => {
    return materialToken.mint(asset, 0);
  });
  await Promise.all(promises);

  promises = socialAssets.map(asset => {
    return materialToken.mint(asset, 0);
  });
  await Promise.all(promises);

  if (network.name == "hardhat" || network.name == "localhost") {
    const uri = await materialToken.tokenURI(actionAssets.length * 2 + socialAssets.length * 2 - 1);
    const data = atob(uri.substring(29));
    const json = JSON.parse(data);
    const imageData = json.image.substring(26);
    console.log(atob(imageData));
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});