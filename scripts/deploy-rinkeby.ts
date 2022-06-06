// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

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

  // https://etherscan.io/address/0x9c8ff314c9bc7f6e59a9d9225fb22946427edc03#code

  /*
  const Greeter = await ethers.getContractFactory("Greeter");
  const greeter = await Greeter.deploy("hello");

  await greeter.deployed();
  */
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const input = await waitForUserInput("Are you ok?(Y/n)");
  if (input != "Y") {
    process.exit()
    return 
  }
  console.log("deploying....");
  const minter = "0x72B6ac6B5206A3216f8165191b46BA1da4C575BD";
  const descriptor = "0x292c84894c1B86140A784eec99711d6007005f21";
  const seeder = "0x5bcc91c44bffa15c9b804a5fd30174e8da296a4b";
  const proxy = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
    
  const developer = "0x818Fb9d440968dB9fCB06EEF53C7734Ad70f6F0e"; // ai
  const committee = "0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B";
    
  // await deployer.deploy(NFT, minter, descriptor, seeder, developers, proxy);
  
  // 1 eth = 10**18
  const priceSeed = {
    maxPrice:  String(10 ** 16), // 0.01 ether;
    minPrice:  String(5 * 10 ** 13), //  0.00005 ether; = 5 * 10^-3
    priceDelta:  String(15 * 10 ** 13), // 0.00015 ether; = 15 * 10^-2
    timeDelta: 60, // 1 minutes; 
    expirationTime: 90 * 60, // 90 minutes;
  };
  
  // We get the contract to deploy
  const NounsToken = await ethers.getContractFactory("NounsToken");
  const nounsToken = await NounsToken.deploy(descriptor, seeder, developer, committee, priceSeed, proxy);
  
  await nounsToken.deployed();
  
  
  console.log("nounsToken deployed to:", nounsToken.address);

  process.exit()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
