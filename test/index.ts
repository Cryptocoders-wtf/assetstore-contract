import { expect } from "chai";
import { ethers } from "hardhat";

describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const Greeter = await ethers.getContractFactory("contracts/libs/Base64.sol:Base64");
    const greeter = await Greeter.deploy();
    await greeter.deployed();
  
    const result = await greeter.encode("Hello World");
    expect(atob(result)).to.equal("Hello World");
    console.log(result);
  });
});

