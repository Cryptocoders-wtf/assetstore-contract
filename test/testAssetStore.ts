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

const badAssetBody: any = {
  name: "Bad",
  group: "Fake Material Icons",
  category: "Action",
  minter: "",
  width: 24, height: 24,
  parts:[{
    body: "><script></script><",
    mask: "",
    color: "red"
  }]
};

const badAssetColor: any = {
  name: "Bad",
  group: "Fake Material Icons",
  category: "Action",
  minter: "",
  width: 24, height: 24,
  parts:[{
    body: "",
    mask: "",
    color: "red[]"
  }]
};

const badAssetMask: any = {
  name: "Bad",
  group: "Fake Material Icons",
  category: "Action",
  minter: "",
  width: 24, height: 24,
  parts:[{
    body: "",
    mask: "&%##",
    color: "red"
  }]
};

const badAssetName:any = {
  name: "Bad !$",
  group: "Fake Material Icons",
  category: "Action",
  minter: "",
  width: 24, height: 24,
  parts:[{
      body: "",
      mask: "", color: "red"
  }]
};

const badAssetCategory:any = {
  name: "Bad Cat",
  group: "Fake Material Icons",
  category: "Action||",
  minter: "",
  width: 24, height: 24,
  parts:[{
      body: "",
      mask: "", color: "red"
  }]
};

const badAssetGroup: any = {
  name: "Bad Group",
  group: "Fake Material Icons+",
  category: "Action",
  minter: "",
  width: 24, height: 24,
  parts:[{
      body: "",
      mask: "", color: "red"
  }]
};

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

describe("AssetStore Component Test", function () {
  let asset:any;
  it("Register 'Done'", async function () {
    asset = assetDone;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    const tx = await contract.registerAsset(asset);
    const result = await tx.wait();
    const [event] = result.events;
    expect(event.event).equal("AssetRegistered");
    const assetId = event.args.assetId.toNumber();
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
  });
  it("Register 'Settings'", async function () {
    asset = assetSettings;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
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
  it("Invalid Data Body Test", async function () {
    asset = badAssetBody;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    expect(await catchError(async ()=>{ await contract.registerAsset(asset); })).equal(true);
  });
  it("Invalid Data Color Test", async function () {
    asset = badAssetColor;
    const [owner] = await ethers.getSigners();
    asset.soulbound = owner.address;
    expect(await catchError(async ()=>{ await contract.registerAsset(asset); })).equal(true);
  });
  it("Invalid Data Mask Test", async function () {
    asset = badAssetMask;
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
