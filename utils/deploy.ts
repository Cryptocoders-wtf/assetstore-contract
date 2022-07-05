import { ethers, network } from "hardhat";
import { writeFile } from "fs";

export const developer = "0x6a615Ca8D7053c0A0De2d11CACB6f321CA63BD62"; // sn2
export const proxy = (network.name == "rinkeby") ?
    "0xf57b2c51ded3a29e6891aba85459d600256cf317":
    "0xa5409ec958c83c3f309868babaca7c86dcb077c1"; // openSea proxy

export const deploy:any = async (setWhitelist = true) => {
  const assetStoreFactory = await ethers.getContractFactory("AssetStore");
  const assetStore = await assetStoreFactory.deploy();
  await assetStore.deployed();

  const materialTokenStoreFactory = await ethers.getContractFactory("MaterialToken");
  const materialToken = await materialTokenStoreFactory.deploy(assetStore.address, assetStore.address, developer, proxy);
  await materialToken.deployed();

  if (setWhitelist) {
    const tx = await assetStore.setWhitelistStatus(materialToken.address, true);
    await tx.wait();
  }
  
  let output = `const assetStore = "${assetStore.address}";\n`
    + `const developer = "${developer}"; // sn2\n`
    + `const proxy = "${proxy}";\n`
    + 'module.exports = [assetStore, assetStore, developer, proxy];\n';
  await writeFile('./cache/arguments.js', output, ()=>{});

  return { assetStore, materialToken };
};