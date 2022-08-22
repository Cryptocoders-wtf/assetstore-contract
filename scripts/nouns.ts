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
  const [backgroundCount] = await nounsDescriptorContract.functions.backgroundCount();
  const [bodyCount] = await nounsDescriptorContract.functions.bodyCount();
  const [accessoryCount] = await nounsDescriptorContract.functions.accessoryCount();
  const [headCount] = await nounsDescriptorContract.functions.headCount();
  const [glassesCount] = await nounsDescriptorContract.functions.glassesCount();
  console.log("bodyCount", bodyCount.toNumber());
  const seed = Math.floor(Math.random() * 0x100000000);
  console.log("seed", seed);
  const result2 = await nounsDescriptorContract.functions.generateSVGImage({
    background: seed % backgroundCount.toNumber(),
    body: Math.floor(seed / 13) % bodyCount.toNumber(),
    accessory: Math.floor(seed / 13^2) % accessoryCount.toNumber(),
    head: Math.floor(seed / 13^3) % headCount.toNumber(),
    glasses: Math.floor(seed /13^4) % glassesCount.toNumber()
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
