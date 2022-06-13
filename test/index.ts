//import { expect } from "chai";
import { ethers } from "hardhat";

async function main() {
    const Greeter = await ethers.getContractFactory("contracts/libs/Base64.sol:Base64");
    const greeter = await Greeter.deploy();
    await greeter.deployed();

    const result = await greeter.encode("Hello World");
    console.log(result);

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
