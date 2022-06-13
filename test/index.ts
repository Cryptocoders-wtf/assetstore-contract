import { expect } from "chai";
import { ethers } from "hardhat";

describe("Base64", function () {
  it("Verify encode", async function () {
    const Base64Factory = await ethers.getContractFactory("contracts/libs/Base64.sol:Base64");
    const base64 = await Base64Factory.deploy();
    await base64.deployed();
  
    const messages = [
      "Hello World",
      "<svg>foobar</svg>",
    ];
    const processes = messages.map(async (message) => {
      const result = await base64.encode(message);
      expect(atob(result)).to.equal(message);
    });
    return Promise.all(processes);
  });
});
