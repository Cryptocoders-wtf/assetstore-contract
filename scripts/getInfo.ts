import { ethers } from "hardhat";

async function main() {
  const nounsToken = process.env.NOUNSVILLE_ADDRESS as string;
  const priceSeed = {
    maxPrice:    String(3 * 10 ** 18),  // 3 ether;
    minPrice:    String(25 * 10 ** 15), // 0.025 ether; = 25 * 10^-3
    priceDelta:  String(50 * 10 ** 15), // 0.050 ether; = 50 * 10^-3
    timeDelta: 60, // 1 minutes; 
    expirationTime: 90 * 60, // 90 minutes;
  };

  // We get the contract to deploy
  const NounsToken = await ethers.getContractFactory("NounsvilleToken");
  const descriptorContract = NounsToken.attach(nounsToken);

  await descriptorContract.setPriceData(priceSeed);

  const data = await descriptorContract.getPriceData();
  console.log(data);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
