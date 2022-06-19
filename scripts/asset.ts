
import { ethers, network } from "hardhat";

async function main() {
  const factory = await ethers.getContractFactory("AssetStore");
  const contract = await factory.deploy();
  await contract.deployed();
  const parts = [
    {
      body: "body string",
      mask: "mask string",
      color: "color string"
    },
    {
      body: "body string1",
      mask: "mask string1",
      color: "color string1"
    }
  ];

  let result:any = await contract.registerAsset(parts);
  result = await contract.getAssetCount();
  console.log("assetCount", result);
  result = await contract.getAsset(0);
  console.log("getAsset", result);
  //console.log('data:image/svg+xml;base64,' + btoa(result));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});