
import { SSL_OP_EPHEMERAL_RSA } from "constants";
import { ethers, network } from "hardhat";
import { actionAssets } from "../data/materials";

async function main() {
  const assetStoreFactory = await ethers.getContractFactory("AssetStore");
  const assetStore = await assetStoreFactory.deploy();
  await assetStore.deployed();

  const materialTokenStoreFactory = await ethers.getContractFactory("MaterialToken");
  const materialToken = await materialTokenStoreFactory.deploy(assetStore.address, assetStore.address);
  await materialToken.deployed();

  const tx = await assetStore.setWhitelistStatus(materialToken.address, true);
  await tx.wait();

  const promises:Array<Promise<any>> = actionAssets.map(asset => {
    return materialToken.mint(asset, 0);
  });
  await Promise.all(promises);

  if (network.name == "hardhat" || network.name == "localhost") {
    const uri = await materialToken.tokenURI(actionAssets.length * 2 - 1);
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