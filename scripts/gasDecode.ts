
import { ethers, network } from "hardhat";
import { kamonAssets } from "../assets/kamons";
import { writeFile } from "fs";

import { deploy, developer, proxy } from "../utils/deploy";
import { gasEstimate } from "../utils/math";

const waitForUserInput = (text: string) => {
  return new Promise((resolve, reject) => {
    process.stdin.resume()
    process.stdout.write(text)
    process.stdin.once('data', data => resolve(data.toString().trim()))
  })
};

async function main() {



  const { assetStore, materialToken } = await deploy();

  const benchMarkFactory = await ethers.getContractFactory("Benchmark");
  const benchMark = await benchMarkFactory.deploy(assetStore.address);
  await benchMark.deployed();

  const SVGFactory = await ethers.getContractFactory("SVGPathDecoder3");
  const decoder = await SVGFactory.deploy();
  await decoder.deployed();
  const tx = await assetStore.setPathDecoder(decoder.address);
  const result = await tx.wait();

  const factory = await ethers.getContractFactory("KamonToken");
  const kamonToken = await factory.deploy(assetStore.address, assetStore.address, developer, proxy);
  await kamonToken.deployed();

  const tx2 = await assetStore.setWhitelistStatus(kamonToken.address, true);
  await tx2.wait();

  const addresses = `export const kamon_addresses = {\n`
  + `  decoderAddress:"0xAa37fA6cEb855500E269513cA9e6E5F13B4D0D95",\n`
  + `  kamonAddress:"${kamonToken.address}"\n`
  + `}\n`;
  await writeFile(`./cache/addresses_kamon_${network.name}.ts`, addresses, ()=>{});


  const [owner] = await ethers.getSigners();

  const mintAssets = async (assets:Array<any>) => {
    let results = [];
    let i;
    for (i=0; i<assets.length; i++) {
      assets[i].soulbound = owner.address;
      assets[i].group = ""; // gas saving
      const tx = await kamonToken.mintWithAsset(assets[i], 0);
      const result = await tx.wait();
      const txBench = await benchMark.measure(i+1);
      const rsBench = await txBench.wait();
      const ret = gasEstimate(rsBench);
      results.push(ret);
    }
    return results;
  };

  const kamons = await mintAssets(kamonAssets);

  console.log("const gas =", { kamons }, ";");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});