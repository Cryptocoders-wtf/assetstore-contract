import { expect } from "chai";
import { ethers } from "hardhat";
import { actionAssets, socialAssets } from "../assets/materials";

let contract :any = null;
const assetDone:any = actionAssets[0];
const assetSettings:any = actionAssets[1];
const assetAccount:any = actionAssets[2];
assetAccount.group = "Material 2";
const assetHome:any = socialAssets[0];
assetHome.group = "Material 2";

const badAssetColor= Object.assign({}, actionAssets[1]);
badAssetColor.group = "Bad";
badAssetColor.parts = [{
  color: "#fff~", body: badAssetColor.parts[0].body
}];

const badAssetName= Object.assign({}, actionAssets[2]);
badAssetName.group = "Bad";
badAssetName.name = "Bad$";

const badAssetCategory= Object.assign({}, actionAssets[3]);
badAssetCategory.group = "Bad";
badAssetCategory.category = "Action||";

const badAssetGroup= Object.assign({}, actionAssets[4]);
badAssetGroup.group = "Fake Material Icons+";

before(async () => {
  const factory = await ethers.getContractFactory("AssetStore");    
  contract = await factory.deploy();
  await contract.deployed();
});
const catchError = async (callback: any) => {
  try {
    await callback();
    return false;
  } catch(e:any) {
    // console.log(e.reason);
    return true;
  }
};
const encoder = new TextEncoder();
const decoder = new TextDecoder();

describe("AssetStore Component Test", function () {
  let asset:any;
  it("Register 'Done'", async function () {
    asset = assetDone;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    const tx = await contract.registerAsset(asset);
    const result = await tx.wait();
    const [event1, event2, event3] = result.events;
    expect(event1.event).equal("GroupAdded");
    expect(event2.event).equal("CategoryAdded");
    expect(event3.event).equal("AssetRegistered");
    const assetId = event3.args.assetId.toNumber();
    expect(await contract.getAssetCount()).equal(assetId);    
    expect(await contract.getGroupCount()).equal(1);    
    expect(await contract.getGroupNameAtIndex(0)).equal(asset.group);    
    expect(await contract.getCategoryCount(asset.group)).equal(1);    
    expect(await contract.getCategoryNameAtIndex(asset.group, 0)).equal(asset.category);   
    expect(await contract.getAssetCountInCategory(asset.group, asset.category)).equal(1);    
    expect(await contract.getAssetIdInCategory(asset.group, asset.category, 0)).equal(assetId);
    expect(await contract.getAssetIdWithName(asset.group, asset.category, asset.name)).equal(assetId);
    const attr: any = await contract.getAttributes(assetId);
    expect(attr.name == asset.name && attr.group == asset.group && attr.category==asset.category).equal(true);
    expect(attr.minter == asset.minter && attr.soulbound == asset.soulbound).equal(true);
    expect(ethers.utils.arrayify(attr.metadata).length).equal(0);
  });
  it("Register 'Settings'", async function () {
    asset = assetSettings;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    asset.metadata = encoder.encode("abc");
    const tx = await contract.registerAsset(asset);
    const result = await tx.wait();
    const [event] = result.events;
    const assetId = event.args.assetId.toNumber();
    expect(await contract.getAssetCount()).equal(assetId);    
    expect(await contract.getGroupCount()).equal(1);    
    expect(await contract.getGroupNameAtIndex(0)).equal(asset.group);    
    expect(await contract.getCategoryCount(asset.group)).equal(1);    
    expect(await contract.getCategoryNameAtIndex(asset.group, 0)).equal(asset.category);    
    expect(await contract.getAssetCountInCategory(asset.group, asset.category)).equal(2);    
    expect(await contract.getAssetIdInCategory(asset.group, asset.category, 1)).equal(assetId);    
    expect(await contract.getAssetIdWithName(asset.group, asset.category, asset.name)).equal(assetId);
    const attr: any = await contract.getAttributes(assetId);
    expect(attr.name == asset.name && attr.group == asset.group && attr.category==asset.category).equal(true);
    expect(attr.minter == asset.minter && attr.soulbound == asset.soulbound).equal(true);
    expect(decoder.decode(ethers.utils.arrayify(attr.metadata))).equal("abc");
  });
  it("Register 'Account'", async function () {
    asset = assetAccount;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    await contract.registerAsset(asset);
    expect(await contract.getAssetCount()).equal(3);    
    expect(await contract.getGroupCount()).equal(2);    
    expect(await contract.getGroupNameAtIndex(1)).equal(asset.group);    
    expect(await contract.getCategoryCount(asset.group)).equal(1);    
    expect(await contract.getCategoryNameAtIndex(asset.group, 0)).equal(asset.category);    
    expect(await contract.getAssetCountInCategory(asset.group, asset.category)).equal(1);    
    expect(await contract.getAssetIdInCategory(asset.group, asset.category, 0)).equal(3);    
    expect(await contract.getAssetIdWithName(asset.group, asset.category, asset.name)).equal(3);
  });
  it("Register 'Home'", async function () {
    asset = assetHome;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    await contract.registerAsset(asset);
    expect(await contract.getAssetCount()).equal(4);    
    expect(await contract.getGroupCount()).equal(2);    
    expect(await contract.getCategoryCount(asset.group)).equal(2);    
    expect(await contract.getCategoryNameAtIndex(asset.group, 1)).equal(asset.category);    
    expect(await contract.getAssetCountInCategory(asset.group, asset.category)).equal(1);    
    expect(await contract.getAssetIdInCategory(asset.group, asset.category, 0)).equal(4);    
    expect(await contract.getAssetIdWithName(asset.group, asset.category, asset.name)).equal(4);
  });
  it("Invalid Data Color Test", async function () {
    asset = badAssetColor;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    expect(await catchError(async ()=>{ await contract.registerAsset(asset); })).equal(true);
  });
  it("Invalid Name Data Test", async function () {
    asset = badAssetName;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    expect(await catchError(async ()=>{ await contract.registerAsset(asset); })).equal(true);
  });
  it("Invalid Category Data Test", async function () {
    asset = badAssetCategory;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    expect(await catchError(async ()=>{ await contract.registerAsset(asset); })).equal(true);
  });
  it("Invalid Group Data Test", async function () {
    asset = badAssetGroup;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    expect(await catchError(async ()=>{ await contract.registerAsset(asset); })).equal(true);
  });
  it("Duplicate", async function () {
    expect(await catchError(async ()=>{ await contract.registerAsset(assetDone); })).equal(true);
    expect(await catchError(async ()=>{ await contract.registerAsset(assetSettings); })).equal(true);
    expect(await catchError(async ()=>{ await contract.registerAsset(assetAccount); })).equal(true);
    expect(await catchError(async ()=>{ await contract.registerAsset(assetHome); })).equal(true);
  });
  it("Disable", async function () {
    await contract.setDisabled(1, true);
    expect(await catchError(async ()=>{ await contract.generateSVG(1); })).equal(true);
    await contract.setDisabled(1, false);
    expect(await catchError(async ()=>{ await contract.generateSVG(1); })).equal(false);
  });
});
