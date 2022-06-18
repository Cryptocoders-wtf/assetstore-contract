import { expect } from "chai";
import { ethers } from "hardhat";

let contract :any = null;

before(async () => {
  const factory = await ethers.getContractFactory("PrideSquiggle");    
  const limit = 10000;
  const developer = "0x6a615Ca8D7053c0A0De2d11CACB6f321CA63BD62"; // sn2
  const proxy = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  contract = await factory.deploy(limit, developer, proxy);
  await contract.deployed();
});
describe("Baisc", function () {
  it("generateSVG", async function () {
    const result = await contract.generateSVG(3);
    console.log(result);
    expect(result.startsWith("<svg width")).equal(true);    
  });
  it("SetLimit", async function () {
    await contract.setLimit(3);
    const data = await contract.limit();
    console.log(data);
    expect(data).equal(3);
  });
  it("SetDesc", async function () {
    await contract.setDescription("Test!");
    const desc = await contract.description();
    console.log(desc);
    expect(desc).equal("Test!");
  });
  it("Mint", async function () {
    const transaction = await contract.mint();
    console.log(transaction);
    expect(transaction.value).equal(0);
  });
  it("Mint2nd", async function () {
    try{
      // mint twice should cause error
      await contract.mint()
    } catch(e){
      console.log(e);
     return; 
    }
    expect.fail("should happen exception")
  });
  it("tokenURI", async function () {
    const result = await contract.tokenURI(0);
    console.log(result);
    expect(result.startsWith("data:image/svg+xml;base64,")).equal(true);    
    //this test fails, because actual return data:application/json;base64,...;
  });
});
