import { ethers, network } from "hardhat";
import { ChainId, getContractAddressesForChainOrThrow, getContractsForChainOrThrow } from '@nouns/sdk';
import { token_addresses as local_addresses } from '../cache/addresses_draw_localhost';
import { token_addresses as rinkeby_addresses } from '../cache/addresses_draw_rinkeby';
import { token_addresses as goerli_addresses } from '../cache/addresses_draw_goerli';

const getRegistryAddress = () => {
  if (network.name == "localhost") {
    return local_addresses.registryAddress;
  } else if (network.name == "rinkeby") {
    return rinkeby_addresses.registryAddress;
  } else if (network.name == "goerli") {
    return goerli_addresses.registryAddress;
  }
  return "error";
};

const registryAddress = getRegistryAddress();

const chainId = (network.name == "rinkeby") ? ChainId.Rinkeby : ChainId.Mainnet;
console.log("network", network.name, chainId);
var nounsDescriptor:string;
if (network.name == "goerli") {
  nounsDescriptor = "0x4d1e7066EEbA8F6c86033F3728C004E71328326D"; // HACK
} else {
  const addresses = getContractAddressesForChainOrThrow(chainId);
  nounsDescriptor = addresses.nounsDescriptor;
}
console.log("nounsDescriptor", nounsDescriptor);

async function main() {
  const nounsFactory = await ethers.getContractFactory("NounsAssetProvider");
  const nounsProvider = await nounsFactory.deploy(nounsDescriptor);
  await nounsProvider.deployed();
  console.log(`      nounsProvider="${nounsProvider.address}"`);

  const registryFactory = await ethers.getContractFactory("AssetProviderRegistry");
  const registry = registryFactory.attach(registryAddress);

  console.log("about to call registerProvider")

  const tx = await registry.functions.registerProvider(nounsProvider.address);
  const result = await tx.wait();
  console.log("events", result.events);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
