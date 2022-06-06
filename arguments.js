const minter = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";
const descriptor = "0x0cfdb3ba1694c2bb2cfacb0339ad7b1ae5932b63";
const seeder = "0xcc8a0fb5ab3c7132c1b2a0109142fb112c4ce515";

const proxy = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";

const developer = "0x818Fb9d440968dB9fCB06EEF53C7734Ad70f6F0e"; // ai
const committee = "0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B";

// await deployer.deploy(NFT, minter, descriptor, seeder, developers, proxy);

// 1 eth = 10**18
const priceSeed = {
  maxPrice:  String(10 ** 16), // 0.01 ether; = 1 * 10^2
  minPrice:  String(5 * 10 ** 13), //  0.00005 ether; = 5 * 10^-5
  priceDelta:  String(15 * 10 ** 13), // 0.00015 ether; = 15 * 10^-5
  timeDelta: 60, // 1 minutes; 
  expirationTime: 90 * 60, // 90 minutes;
};

module.exports = [
    descriptor,
    seeder,
    developer,
    committee,
    priceSeed,
    proxy
  ];