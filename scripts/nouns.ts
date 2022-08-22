import { ethers, network } from "hardhat";
import { developer, proxy } from "../utils/deploy";
import { storeAddress } from "../utils/storeAddress";
import { writeFile } from "fs";
import { ChainId, getContractAddressesForChainOrThrow, getContractsForChainOrThrow } from '@nouns/sdk';

const chainId = (network.name == "rinkeby") ? ChainId.Rinkeby : ChainId.Mainnet;
console.log("network", network.name, chainId);
const { nounsToken } = getContractAddressesForChainOrThrow(chainId);
console.log("nounsToken", nounsToken);
const provider =
network.name == "localhost"
  ? new ethers.providers.JsonRpcProvider()
  : new ethers.providers.AlchemyProvider(network.name);
const { nounsTokenContract, nounsDescriptorContract, nounsSeederContract } = getContractsForChainOrThrow(chainId, provider);

async function main() {
  console.log("nounsToken", nounsTokenContract.address);
  const result = await nounsDescriptorContract.functions.bodyCount();
  console.log("result", result[0].toNumber());
  const result2 = await nounsDescriptorContract.functions.generateSVGImage({
    background: 1,
    body: 1,
    accessory: 0,
    head: 1,
    glasses: 2
  });
  //console.log(atob(result2[0]));
  await writeFile(`./cache/test.svg`, atob(result2[0]), ()=>{});
  const result3 = await nounsDescriptorContract.functions.bodies(0);
  console.log("bodies", result3);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
