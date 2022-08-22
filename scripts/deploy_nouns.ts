import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";
import { writeFile } from "fs";
import { ChainId, getContractAddressesForChainOrThrow, getContractsForChainOrThrow } from '@nouns/sdk';

const chainId = (network.name == "rinkeby") ? ChainId.Rinkeby : ChainId.Mainnet;
console.log("network", network.name, chainId);
const { nounsDescriptor } = getContractAddressesForChainOrThrow(chainId);
console.log("nounsDescriptor", nounsDescriptor);

async function main() {
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
