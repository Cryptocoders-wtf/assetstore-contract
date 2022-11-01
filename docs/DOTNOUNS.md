I have been prototyping various fully on-chain generative art (written in Solidity), including some derivative work of Nouns characters retrieved from NounsDescriptor.

I finally came up with one, which we would like to release to the public as an NFT collection. 

![](upload://fmhVcMaGYhlo3diDFzjGfelrkKe.jpeg)

I call it **dotNouns**, and would like to use it to raise money for **Children's Hospitals**. 

Here is my plan. 

1. Nouners can mint corresponding dotNouns NFTs for free.
2. Other people can mint dotNouns NFTs (total 10,000), but they need to pay 0.01ETH, which will be sent to Children's Hospitals directly via the Giving Block.
3. 5% of secondary sales will be also sent to Children's Hospital.

## About me (NounsFes, Satoshi Nakajima)

I'm a software developer & entrepreneur, with over 30 years of software development experience including compiler, operating system, CAD, mobile apps, web services, and web3 apps. 

I joined NounsDAO in April 2022 and was very impressed by the architecture of Nouns, which generates all the art on the blockchain (unlike many other NFTs.

Inspired by Nouns, I started an open-source initiative, "Fully On Chain"[https://fullyonchain.xyz/], to promote fully on-chain generative art. I have released a few on-chain generative art NFT collections.

## Unique aspects of this NFT collections

This NFT collection is quite unique for the following reasons. 

- It retrieves Nouns characters from NounsDescriptor and dynamically generates a new art, all on the blockchain. It demonstrates the power of **composability**, which is one of the unique aspects of Web3.
- Just like Nouns, this art itself is fully generated on the blockchain. It means it is fully **decentralized** (it does not rely on either HTTP servers or IPFS), and is guaranteed to exist as long as the Ethereum blockchain exists.
- It demonstrates the power of CC0, which allows anybody to create new art from Nouns. The power of the **permissionless** culture of Nouns. 

## Architecture

Here is the architecture of this NFT collection. 

![](https://i.imgur.com/xV0ezuq.png)

1. NounsAssetProvider retrieves an SVG image from NounsDescriptor, decodes base64, removes unnecessary tags, and returns it as a reusable SVG component via IAssetProvider interface.
2. DotProvider retrieves a Nouns character image from NounsAssetProivder, converts it into dotNouns, and returns it via IAssetProvider interface. 
3. DotNounsToken retrieves a dotNouns character and mints an NFT out of it. It accesses NounsToken contract to retrieve an appropriate seed when a Nouner mints an NFT. 

