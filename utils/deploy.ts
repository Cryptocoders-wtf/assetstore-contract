import { ethers } from "hardhat";

export const developer = "0x6a615Ca8D7053c0A0De2d11CACB6f321CA63BD62"; // sn2
const proxy = "0xa5409ec958c83c3f309868babaca7c86dcb077c1"; // openSea proxy

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

  return { assetStore, materialToken };
};