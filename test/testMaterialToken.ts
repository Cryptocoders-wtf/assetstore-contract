import { expect } from "chai";
import { ethers } from "hardhat";
import { actionAssets } from "../assets/materials";
import { deploy, developer } from "../utils/deploy";

let assetStore :any = null;
let materialToken: any = null;
const assetDone:any = actionAssets[0];
const assetSettings:any = actionAssets[1];
const assetAccount:any = actionAssets[2];
const assetHome:any = actionAssets[3];

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

describe("MaterialToken minting test", function () {
  let asset:any;
  it("Without Whitelist", async function () {
    expect(await catchError(async ()=>{ await materialToken.mintWithAsset(assetDone, 0); })).equal(true);
  });
  it("First mint", async function () {
    const [owner] = await ethers.getSigners();
    assetDone.soulbound = owner.address;
    await assetStore.setWhitelistStatus(materialToken.address, true);
    await materialToken.mintWithAsset(assetDone, 0);
    expect(await materialToken.balanceOf(owner.address)).equal(2);

    expect(await materialToken.balanceOf(developer)).equal(1);
    expect(await materialToken.getCurrentToken()).equal(3); // including developer token    

    await assetStore.setWhitelistStatus(materialToken.address, false);
    expect(await catchError(async ()=>{ await materialToken.mintWithAsset(assetHome, 0); })).equal(true);
    await assetStore.setWhitelistStatus(materialToken.address, true);
  });
  it("Affiliated mint", async function () {
    const [owner, user1, user2] = await ethers.getSigners();
    const materialToken1 = materialToken.connect(user1);
    const materialToken2 = materialToken.connect(user2);
    assetSettings.soulbound = user1.address;
    await materialToken1.mintWithAsset(assetSettings, 0);
    expect(await materialToken.balanceOf(user1.address)).equal(2);

    const tokenId = 3; // await materialToken.tokenOfOwnerByIndex(user1.address, 0); 
    expect(await materialToken.ownerOf(tokenId)).equal(user1.address);
    
    assetAccount.soulbound = user2.address;
    await materialToken2.mintWithAsset(assetAccount, tokenId);
    expect(await materialToken.balanceOf(user2.address)).equal(2);    
    expect(await materialToken.balanceOf(user1.address)).equal(3); // affiliate    

    expect(await materialToken.balanceOf(developer)).equal(1);
    expect(await materialToken.getCurrentToken()).equal(3 + 5);     
  });
  it("Duplicated assets", async function () {
    const [owner] = await ethers.getSigners();
    assetDone.soulbound = owner.address;
    assetSettings.soulbound = owner.address;
    assetAccount.soulbound = owner.address;
    expect(await catchError(async ()=>{ await materialToken.mintWithAsset(assetDone, 0); })).equal(true);
    expect(await catchError(async ()=>{ await materialToken.mintWithAsset(assetSettings, 0); })).equal(true);
    expect(await catchError(async ()=>{ await materialToken.mintWithAsset(assetAccount, 0); })).equal(true);
  });
  it("Disabled Whitelist", async function () {
    await assetStore.setWhitelistStatus(materialToken.address, false);
    const [owner] = await ethers.getSigners();
    assetHome.soulbound = owner.address;
    expect(await catchError(async ()=>{ await materialToken.mintWithAsset(assetHome, 0); })).equal(true);
    await assetStore.setDisableWhitelist(true);
    await materialToken.mintWithAsset(assetHome, 0);
  });
  it("Verify onlyOwner security", async function () {
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
