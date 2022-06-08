// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, network } from "hardhat";

const waitForUserInput = (text: string) => {
  return new Promise((resolve, reject) => {
    process.stdin.resume()
    process.stdout.write(text)
    process.stdin.once('data', data => resolve(data.toString().trim()))
  })
};

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const isRinkeby = network.name == "rinkeby";
  console.log("deploying...", network.name, isRinkeby ? "testnet": "*", process.env.ALCHEMY_API_KEY);

  const input = await waitForUserInput("Are you ok?(Y/n)");
  if (input != "Y") {
    process.exit()
    return 
  }
  
  // We get the contract to deploy
  const factory = await ethers.getContractFactory("MessageBox");
  const contract = await factory.deploy();

  await contract.deployed();
  
  console.log("MessageBox deployed to:", contract.address);
  process.exit()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
