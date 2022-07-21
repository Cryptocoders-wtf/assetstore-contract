
import { ethers, network } from "hardhat";
import { kamonAssets } from "../assets/kamons";

import { deploy } from "../utils/deploy";
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
  const benchMark = await benchMarkFactory.deploy();
  await benchMark.deployed();

  const [owner] = await ethers.getSigners();
  const unitPrice = ethers.BigNumber.from(55);

  const mintAssets = async (assets:Array<any>) => {
    let results = [];
    let i;
    for (i=0; i<assets.length; i++) {
      assets[i].soulbound = owner.address;
      assets[i].group = ""; // gas saving
      const tx = await materialToken.mintWithAsset(assets[i], 0);
      const result = await tx.wait();
      const txBench = await benchMark.measure();
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