import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";

async function main() {
  const [owner] = await ethers.getSigners();
  console.log("network:", network.name);
  console.log("storeAddress:", storeAddress);

  const factory = await ethers.getContractFactory("KamonToken");
  const kamonToken = await factory.deploy(storeAddress, storeAddress, developer, proxy);
  await kamonToken.deployed();
  console.log(`      kamonToken="${kamonToken.address}"`);

  /*
  if (setWhitelist) {
    const tx = await assetStore.setWhitelistStatus(materialToken.address, true);
    await tx.wait();
  }
  */
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});