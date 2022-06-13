import { expect } from "chai";
import { ethers } from "hardhat";

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Base64");
    const greeter = await Greeter.deploy();
    await greeter.deployed();

    const result = await greeter.encode("Hello World");
    console.log(result);

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
