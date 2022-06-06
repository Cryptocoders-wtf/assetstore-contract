import { ethers } from "hardhat";

async function main() {
  const nounsToken = "0x2DfB7180669396D812Ec7F90011857d81873af55";

  // We get the contract to deploy
  const NounsToken = await ethers.getContractFactory("NounsToken");
  const descriptorContract = NounsToken.attach(nounsToken);

  //await descriptorContract.getPriceData(priceSeed);

  const data = await descriptorContract.getPriceData();
  console.log(data);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
