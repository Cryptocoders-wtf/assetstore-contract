import { ethers, network } from "hardhat";
//import { socialAssets } from "../assets/materials";

import { addresses as addresses_localhost} from "../cache/addresses_localhost";
import { addresses as addresses_rinkeby} from "../cache/addresses_rinkeby";
import { addresses as addresses_mainnet} from "../cache/addresses_mainnet";

type AddressForChain = {
  [network: string]: string;
};

const addresses: AddressForChain = {
  mainnet: addresses_mainnet.storeAddress,
  rinkeby: addresses_rinkeby.storeAddress,
  localhost: addresses_localhost.storeAddress
};

async function main() {
  const [owner] = await ethers.getSigners();
  console.log("network:", network.name);
  console.log("network:", addresses[network.name]);
//  console.log(`      storeAddress="${assetStore.address}"`);
//  console.log(`      tokenAddress="${materialToken.address}"`);

  /*
  const asset = socialAssets[5];
  asset.soulbound = owner.address;
  const tx = await materialToken.mintWithAsset(asset, 0);
  const result = await tx.wait();
  console.log("gasUsed:", result.gasUsed.toNumber());
  */
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});