
import { SSL_OP_EPHEMERAL_RSA } from "constants";
import { ethers, network } from "hardhat";
import { actions } from "../data/materials";

const assetBase:any = {
  width: 24, height: 24,
  group: "Material Icons (Apache 2.0)",
  minterName: "nounsfes",
  parts:[{
      mask: "", color: ""
  }]
};

function delay(ms: any) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  let result:any;
  const assetStoreFactory = await ethers.getContractFactory("AssetStore");
  const assetStore = await assetStoreFactory.deploy();
  await assetStore.deployed();
  //console.log("assetStore address", assetStore.address);
  const materialTokenStoreFactory = await ethers.getContractFactory("MaterialToken");
  const materialToken = await materialTokenStoreFactory.deploy(assetStore.address, assetStore.address);
  await materialToken.deployed();
  //console.log("materialToken address", assetStore.address);
  const tx = await assetStore.setWhitelistStatus(materialToken.address, true);
  await tx.wait();

  let asset = Object.assign({}, assetBase);
  let i:number;
  for(i = 0; i < 6; i++) {
    let material = actions[i];
    asset.name = material.name;
    asset.category = "Action";
    asset.parts[0].body = material.body;
    if (i % 2 == 0) {
      asset.minterName = "";
    }
    await materialToken.mint(asset, 0);
  }

  const assetId = await materialToken.getAssetId(11);
  
  // await assetStore.setDisabled(assetId, true);

  const uri = await materialToken.tokenURI(11);
  const data = atob(uri.substring(29));
  const json = JSON.parse(data);
  const imageData = json.image.substring(26);
  console.log(atob(imageData));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});