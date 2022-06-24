import { expect } from "chai";
import { ethers } from "hardhat";
import { actionAssets } from "../data/materials";
import { deploy } from "../utils/deploy";

let assetStore :any = null;
let materialToken: any = null;
const assetDone:any = {
  name: "Done",
  group: "Material Icons",
  category: "Action",
  minterName: "nounsfes",
  width: 24, height: 24,
  parts:[{
      body: "M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z",
      mask: "", color: "black"
  }]
};
const assetSettings:any = {
  name: "Settings",
  group: "Material Icons",
  category: "Action",
  minterName: "nounsfes",
  width: 24, height: 24,
  parts:[{
      body: "M19.14,12.94c0.04-0.3,0.06-0.61,0.06-0.94c0-0.32-0.02-0.64-0.07-0.94l2.03-1.58c0.18-0.14,0.23-0.41,0.12-0.61 l-1.92-3.32c-0.12-0.22-0.37-0.29-0.59-0.22l-2.39,0.96c-0.5-0.38-1.03-0.7-1.62-0.94L14.4,2.81c-0.04-0.24-0.24-0.41-0.48-0.41 h-3.84c-0.24,0-0.43,0.17-0.47,0.41L9.25,5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22-0.08-0.47,0-0.59,0.22L2.74,8.87 C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.07,0.94l-2.03,1.58 c-0.18,0.14-0.23,0.41-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.22l2.39-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54 c0.05,0.24,0.24,0.41,0.48,0.41h3.84c0.24,0,0.44-0.17,0.47-0.41l0.36-2.54c0.59-0.24,1.13-0.56,1.62-0.94l2.39,0.96 c0.22,0.08,0.47,0,0.59-0.22l1.92-3.32c0.12-0.22,0.07-0.47-0.12-0.61L19.14,12.94z M12,15.6c-1.98,0-3.6-1.62-3.6-3.6 s1.62-3.6,3.6-3.6s3.6,1.62,3.6,3.6S13.98,15.6,12,15.6z",
      mask: "", color: "blue"
  }]
};
const assetAccount:any = {
  name: "Account Circle",
  group: "Material Icons 2",
  category: "Action",
  minterName: "nounsfes",
  width: 24, height: 24,
  parts:[{
      body: "M12,2C6.48,2,2,6.48,2,12s4.48,10,10,10s10-4.48,10-10S17.52,2,12,2z M12,6c1.93,0,3.5,1.57,3.5,3.5S13.93,13,12,13 s-3.5-1.57-3.5-3.5S10.07,6,12,6z M12,20c-2.03,0-4.43-0.82-6.14-2.88C7.55,15.8,9.68,15,12,15s4.45,0.8,6.14,2.12 C16.43,19.18,14.03,20,12,20z",
      mask: "", color: "red"
  }]
};
const assetHome:any = {
  name: "Home",
  group: "Material Icons 2",
  category: "Action 2",
  minterName: "",
  width: 24, height: 24,
  parts:[{
      body: "M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z",
      mask: "", color: "red"
  }]
};

before(async () => {
  const result = await deploy(false);
  assetStore = result.assetStore;
  materialToken = result.materialToken;
});
const catchError = async (callback: any) => {
  try {
    await callback();
    console.log("success");
    return false;
  } catch(e:any) {
    // console.log(e.reason);
    return true;
  }
};

describe("Baisc", function () {
  let asset:any;
  it("Without Whitelist", async function () {
    expect(await catchError(async ()=>{ await materialToken.mint(assetDone, 0); })).equal(true);
  });
  it("First mint", async function () {
    const [owner] = await ethers.getSigners();
    await assetStore.setWhitelistStatus(materialToken.address, true);
    await materialToken.mint(assetDone, 0);
    expect(await materialToken.balanceOf(owner.address)).equal(2);    

    await assetStore.setWhitelistStatus(materialToken.address, false);
    expect(await catchError(async ()=>{ await materialToken.mint(assetHome, 0); })).equal(true);
    await assetStore.setWhitelistStatus(materialToken.address, true);
  });
  it("Affiliate", async function () {
    const [owner, user1, user2] = await ethers.getSigners();
    const materialToken1 = materialToken.connect(user1);
    const materialToken2 = materialToken.connect(user2);
    await materialToken1.mint(assetSettings, 0);
    expect(await materialToken.balanceOf(user1.address)).equal(2);   
    const tokenId = await materialToken.tokenOfOwnerByIndex(user1.address, 0); 
    await materialToken2.mint(assetAccount, tokenId);
    expect(await materialToken.balanceOf(user2.address)).equal(2);    
    expect(await materialToken.balanceOf(user1.address)).equal(3); // affiliate    
  });
  it("Duplicate", async function () {
    expect(await catchError(async ()=>{ await materialToken.mint(assetDone, 0); })).equal(true);
    expect(await catchError(async ()=>{ await materialToken.mint(assetSettings, 0); })).equal(true);
    expect(await catchError(async ()=>{ await materialToken.mint(assetAccount, 0); })).equal(true);
  });
  it("DisableWhitelist", async function () {
    await assetStore.setWhitelistStatus(materialToken.address, false);
    expect(await catchError(async ()=>{ await materialToken.mint(assetHome, 0); })).equal(true);
    await assetStore.setDisableWhitelist(true);
    await materialToken.mint(assetHome, 0);
  });
  it("onlyOwner", async function () {
    const [owner, user1] = await ethers.getSigners();
    const assetStore1 = assetStore.connect(user1);
    expect(await catchError(async ()=>{ await assetStore1.setWhitelistStatus(materialToken.address, false); })).equal(true);
    expect(await catchError(async ()=>{ await assetStore1.setDisableWhitelist(true); })).equal(true);
    expect(await catchError(async ()=>{ await assetStore1.setDisabled(1, true); })).equal(true);
    expect(await catchError(async ()=>{ await assetStore1.getRawAsset(1); })).equal(true);
    expect(await catchError(async ()=>{ await assetStore1.getRawPart(1); })).equal(true);
  });
  it("Raw Data", async function () {
    const asset = await assetStore.getRawAsset(1);
    const part = await assetStore.getRawAsset(1);
    //console.log(asset);
    //console.log(part);
  });
});
