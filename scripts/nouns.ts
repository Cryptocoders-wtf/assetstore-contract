import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";
import { writeFile } from "fs";
import { ChainId, getContractAddressesForChainOrThrow } from '@nouns/sdk';

const { nounsToken } = getContractAddressesForChainOrThrow(ChainId.Mainnet);

async function main() {
  console.log("ChainId.Mainnet", ChainId.Mainnet);
  console.log("nounsToken", nounsToken);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
