
import { ethers, network } from "hardhat";

async function main() {
  const factory = await ethers.getContractFactory("AssetStore");
  const contract = await factory.deploy();
  await contract.deployed();
  const parts = [
    {
      body: "M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z",
      mask: "",
      color: ""
    },
  ];

  let result:any = await contract.registerAsset("Google Material/Favorite", parts);
  result = await contract.getAssetCount();
  //console.log("assetCount", result);
  result = await contract.getAsset(0);
  //console.log("getAsset", result);
  result = await contract.getPart(0);
  //console.log("getPart", result);
  result = await contract.generateSVGAsset(0);
  console.log('<svg viewBox="0 0 24 24"  xmlns="http://www.w3.org/2000/svg">', result, '</svg>');
  //console.log('data:image/svg+xml;base64,' + btoa(result));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});