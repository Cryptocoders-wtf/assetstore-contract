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
  console.log(`      contract="${contract.address}"`);

  /*
  const roundRect = [
    { x: 1024 / 4, y: 1024 / 4, c: false, r: 566 },
    { x: 1024 - 1024 / 4, y: 1024 / 4, c: false, r: 566 },
    {
      x: 1024 - 1024 / 4,
      y: 1024 - 1024 / 4,
      c: false,
      r: 566,
    },
    { x: 1024 / 4, y: 1024 - 1024 / 4, c: false, r: 566 },
  ];

  const result0 = await contract.functions.PathFromPoints(roundRect);
  */
  const result0 = await contract.functions.generateSVGPart(0);
  console.log(result0);

  const composerFactory = await ethers.getContractFactory("AssetComposer");
  const composer = composerFactory.attach(composerAddress);

  const tx = await composer.functions.registerProvider(contract.address);
  const result = await tx.wait();
  console.log("events", result.events);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
