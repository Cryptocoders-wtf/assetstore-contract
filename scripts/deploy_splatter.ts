import { ethers, network } from "hardhat";
import { token_addresses as local_addresses } from '../cache/addresses_draw_localhost';
import { token_addresses as rinkeby_addresses } from '../cache/addresses_draw_rinkeby';

const getComposerAddress = () => {
  if (network.name == "localhost") {
    return local_addresses.composerAddress;
  } else if (network.name == "rinkeby") {
    return rinkeby_addresses.composerAddress;
  }
  return "error";
};
const composerAddress = getComposerAddress();

async function main() {
  const factory = await ethers.getContractFactory("SplatterProvider");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      splatter="${contract.address}"`);
  const result0 = await contract.functions.generateSVGPart(0);
  // console.log(result0);

  /*
  const factoryArt = await ethers.getContractFactory("SplatterArtProvider");
  const contractArt = await factoryArt.deploy(contract.address);
  await contractArt.deployed();
  console.log(`      contract="${contractArt.address}"`);
  */

  const composerFactory = await ethers.getContractFactory("AssetComposer");
  const composer = composerFactory.attach(composerAddress);

  const tx = await composer.functions.registerProvider(contract.address);
  const result = await tx.wait();
  const event = result.events && result.events[0];
  if (event) {
    console.log("Splatter event", event.event);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
