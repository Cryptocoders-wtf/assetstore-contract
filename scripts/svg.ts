
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
    }
  ];

  let result = await contract.registerAsset(parts);
  console.log(result);
  result = await contract.registerAsset(parts);
  console.log(result);
  //console.log('data:image/svg+xml;base64,' + btoa(result));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});