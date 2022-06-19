
import { ethers, network } from "hardhat";

async function main() {
  const factory = await ethers.getContractFactory("AssetStore");
  const contract = await factory.deploy();
  await contract.deployed();
  const assets = [{
    name: "Done",
    group: "Material Icons",
    category: "Action",
    parts:[{
        body: "M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z",
        mask: "", color: "black"
    }]
  },{
    name: "Settings",
    group: "Material Icons",
    category: "Action",
    parts:[{
        body: "M19.14,12.94c0.04-0.3,0.06-0.61,0.06-0.94c0-0.32-0.02-0.64-0.07-0.94l2.03-1.58c0.18-0.14,0.23-0.41,0.12-0.61 l-1.92-3.32c-0.12-0.22-0.37-0.29-0.59-0.22l-2.39,0.96c-0.5-0.38-1.03-0.7-1.62-0.94L14.4,2.81c-0.04-0.24-0.24-0.41-0.48-0.41 h-3.84c-0.24,0-0.43,0.17-0.47,0.41L9.25,5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22-0.08-0.47,0-0.59,0.22L2.74,8.87 C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.07,0.94l-2.03,1.58 c-0.18,0.14-0.23,0.41-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.22l2.39-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54 c0.05,0.24,0.24,0.41,0.48,0.41h3.84c0.24,0,0.44-0.17,0.47-0.41l0.36-2.54c0.59-0.24,1.13-0.56,1.62-0.94l2.39,0.96 c0.22,0.08,0.47,0,0.59-0.22l1.92-3.32c0.12-0.22,0.07-0.47-0.12-0.61L19.14,12.94z M12,15.6c-1.98,0-3.6-1.62-3.6-3.6 s1.62-3.6,3.6-3.6s3.6,1.62,3.6,3.6S13.98,15.6,12,15.6z",
        mask: "", color: "blue"
    }]
  },{
    name: "Account Circle",
    group: "Material Icons",
    category: "Action",
    parts:[{
        body: "M12,2C6.48,2,2,6.48,2,12s4.48,10,10,10s10-4.48,10-10S17.52,2,12,2z M12,6c1.93,0,3.5,1.57,3.5,3.5S13.93,13,12,13 s-3.5-1.57-3.5-3.5S10.07,6,12,6z M12,20c-2.03,0-4.43-0.82-6.14-2.88C7.55,15.8,9.68,15,12,15s4.45,0.8,6.14,2.12 C16.43,19.18,14.03,20,12,20z",
        mask: "", color: "red"
    }]
  },{
    name: "Home",
    group: "Material Icons",
    category: "Action",
    parts:[{
        body: "M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z",
        mask: "", color: "red"
    }]
  },{
    name: "Search",
    group: "Material Icons",
    category: "Action",
    parts:[{
        body: "M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
        mask: "", color: "green"
    }]
  },{
    name: "Favorite",
    group: "Material Icons",
    category: "Action",
    parts:[{
        body: "M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z",
        mask: "", color: "green"
    }]
   }];

  let result:any = await contract.registerAssets(assets);
  result = await contract.getAssetCount();
  //console.log("assetCount", result);
  result = await contract.getAsset(0);
  //console.log("getAsset", result);
  result = await contract.getPart(0);
  //console.log("getPart", result);
  result = await contract.generateSVG(0);
  console.log(result);
  //console.log('data:image/svg+xml;base64,' + btoa(result));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});