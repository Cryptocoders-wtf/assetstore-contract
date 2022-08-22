import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";
import { writeFile } from "fs";
import { ChainId, getContractAddressesForChainOrThrow, getContractsForChainOrThrow } from '@nouns/sdk';

const chainId = (network.name == "rinkeby") ? ChainId.Rinkeby : ChainId.Mainnet;
console.log("network", network.name, chainId);
const { nounsToken } = getContractAddressesForChainOrThrow(chainId);
console.log("nounsToken", nounsToken);

async function main() {
  const provider =
  network.name == "localhost"
    ? new ethers.providers.JsonRpcProvider()
    : new ethers.providers.AlchemyProvider(network.name);
const { nounsTokenContract } = getContractsForChainOrThrow(chainId, provider);
console.log("nounsToken", nounsTokenContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
