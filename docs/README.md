# On-Chain Asset Store, Composer and Decentralized Autonomous Marketplace

This is the summary document, which describes the vision & mission of this project and technologies, protocols and methods we are building, such as SVG compression, on-chain asset strore, crowd-Minting, asset providers and Draw2Earn app. 

## Importance of being Fully On-chain

While **decentralization** is one of the fundamental values of Web3, <u>most NFTs (including bluechip NFTs such as BAYC and Azuki) are **not fully on-chain**</u>, storing metadata and images on either HTTP server or IPFS. 

Those NFTs will become inaccessible once the NFT providers cease to exist or simply stop supporting them. 

It means those NFTs are not yours, and they are under the control of NFT providers, just like many Web2 services. They are more like Web 2.5 NFTs. 

On the other hand, <u>**fully on-chain NFTs** such as Nouns are guaranteed to "exist" a hundred years from now</u>, as long as the blockchain exists. 

It means you are the sole owner of those fully on-chain NFTs and nobody is able to take them away from you. "Fully on-chain NFT" means "decentralized NFT" -- the true Web3 spirit!

In addition, fully on-chain NFTs are **composable**. They allow other smart contracts to extra images from them and create a new set of generative arts from them. <u>This composability enables new types of creative art and creates new types of revenue opportunities for artists and developers</u>.

You can easily check if your NFTs are fully on-chain or not by calling tokenURI() method on Etherscan. If the URL starts with "http:" or "ipfs:", they are not on-chain NFTs. <u>The tokenURI method of a **truly decentralized NFT contract** will always return "data:" URL, which is the proof that its metadata and image are stored on-chain</u>. 

![](https://i.imgur.com/8vEdlYu.png)

## Technical Challenges

Despite such an importance, why so many NFTs are not on-chain? The answer is simple, **the gas cost** to store large data on-chain. 

There are some efforts to work around this problem, but there are many technical challenges.

[Nouns](https://nouns.wtf) is one of a few bluechip NFTs, which are also fully on-chain. They have managed to do so, by reducing the resolution of images down to 32x32 pixels and storing them as highly compressed binary data on-chain. 

![](https://i.imgur.com/6BMmUQs.png)

[Cyberbrokers](https://cyberbrokers.io) is the first (and probably the only) project which stores rich graphics on-chain, but they needed to spend over $200,000 to upload a large set of SVG data to the blockchain (a [great podcast](https://rephonic.com/episodes/qc6wd-solidity-galaxy-brain-puzzles-games-and-onch) is available about this story).

![](https://i.imgur.com/Mp9xUwH.jpg)

[Art Blocks](https://www.artblocks.io/) is a great platform to publish generative arts, but Solidity is not an ideal platform for generative arts (yet). As the compromise, <u>they use Javascript to generate arts off-chain</u>, store those scripts on chain (which never run on-chain) and use an HTTP server to store metadata and generated images. 

![](https://i.imgur.com/NxissZu.png)

## Vision and Mission

Considering the current situation, we have determined to create a set of technologies, protocols and mechanisms, which will <u>make it easy and affordable to store, share, generate and compose images on-chain, enabling fully on-chain NFTs with rich graphics</u>.

We also believe that we need to build a **decentralized autonomous marketplace** (automated by smart contracts), where creators can generate revenue from their creations while enabling and encouraging remixes and compositions.

## Our Approach

Here is the list of technologies, protocols and mechanisms we are building. 

### SVG Compression (deployed)

While SVG is the industry standard to exchange vector data, raw SVG data is quite verbose and not suitable as the storage format on the blockchain.

After various prototpes, we have chosen to compress SVG data in the following steps. 

1. We convert all SVG elements to "path" elements, eliminating the need to specify element types (such as "rect" and "circle").
2. We convert all floating points to integers by having a large and fixed view area (integer normolization).
3. We extract only the "d" attribute of those "path" elements, eliminating SVG tags entirely.
4. We compress a series of data (commands and their parameters) in the "d" attribute into a series of 12-bit bytecodes.
5. In this byte code, commands (such as "M" and "C") will be simply expanded to 12-bit (higher 4-bits will be all zero), while parameters (numbers ranging from -1023 to 1023) will be converted to N+1024+256 (higher 4-bits will be non-zero).

```
// Original (368 bytes)
<svg viewBox="0 0 793 793"  xmlns="http://www.w3.org/2000/svg">
  <path d="m 478.845,139.593 c -26.052,-8.349 -53.836,-12.844 -82.656,-12.844 -26.844,0 -52.789,3.901 -77.278,11.177 l 18.825,60.5 c 18.536,-5.409 38.164,-8.306 58.453,-8.306 21.796,0 42.836,3.352 62.601,9.568 z"
   style="fill:#000000;fill-opacity:1;fill-rule:nonzero;stroke:none" />
</svg>

// Integer-Normalized (263 bytes)
<svg viewBox="0 0 1024 1024"  xmlns="http://www.w3.org/2000/svg">
  <path d="m 618 180 c -34 -11 -70 -17 -107 -17 -35 0 -68 5 -100 14 l 24 78 c 24 -7 49 -11 75 -11 28 0 55 4 81 12 z" 
   style="fill:#000000;fill-opacity:1;fill-rule:nonzero;stroke:none" />
</svg>

// Path Extracted (105 bytes)
"m 618 180 c -34 -11 -70 -17 -107 -17 -35 0 -68 5 -100 14 l 24 78 c 24 -7 49 -11 75 -11 28 0 55 4 81 12 z"

// Bytecode (50 bytes)
0x6d,0x70,0x6a,0xb4,0x5,0x63,0xde,0x44,0xf5,0xba,0x44,0xef,0x95,0x44,0xef,0xdd,0x54,0x0,0xbc,0x54,0x5,0x9c,0x54,0xe,0x6c,0x50,0x18,0x4e,0x5,0x63,0x18,0x45,0xf9,0x31,0x45,0xf5,0x4b,0x45,0xf5,0x1c,0x55,0x0,0x37,0x55,0x4,0x51,0x55,0xc,0x7a,0x0
```

We perform this encoding off-chain (in TypeScript) before passing the data to the smart contract (on-chain asset store, described below). Please see *compressPath* method in [createMethod.ts](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/utils/createAsset.ts). 

The decoding will be done on-chain in "view" methods, such as *tokenURI* or *generateSVGPart* (in Solidity). Even though there is no "gas cost" associated with it, an efficient implementation is critical to avoid time-out or gas-limit errors. Please see decodePath() method of [SVGPathDecoderA](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/libs/SVGPathDecoderA.sol). 

### On-Chain Asset Store (deployed)

The On-chain Asset Store is a *smart contract*, which acts as **the public on-chain asset storage service**, allowing developers to store and share vector assets.

It stores various vector data in the compressed format described above, and makes them available to other smart contracts, just like the asset store for Unity 3D engine. 

Please see [AssetStore.sol](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/AssetStore.sol) for details. 

### Crowd Minting (deployed)

The "crowd minting" is a *method* to eliminate a large upfront cost for developers when issuing fully on-chain NFT collection (just like the developer of Cyberbrokers did).

Instead, we ask each NFT minter to pay a small extra gas fee which is required to upload necessary vector data to the blockchain during the minting process. 

This is done by calling mintWithAsset() method, which stores the vector data to the On-Chain Asset Store and issues NFT(s) to the minter.

We have launched three NFT collections ([Material Icons](https://assetstore.wtf/material), [Kamon Symbols](https://assetstore.wtf/kamon), [Emoji Flags](https://assetstore.wtf/emoji)) using crowd minting and <u>managed to upload over 1,500 vector images on the Ethereum blockchain</u>.

We also came up with an idea to give addtional rewards to those minters. Please see the "Draw2Earn" section below.

![](https://i.imgur.com/skT6eS5.png)

Please see the mintWithAsset() method of [KamonToken.sol](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/KamonToken.sol) as the reference implementation. 

### Asset Composer (beta testing)

Asset Composer is a *smart contract*, which allows developers and users to create a new vector asset by composing existing vector assets, provided by various asset providers (described below).

Asset Composer is also act as an asset provider, providing compositions as assets. When a composition receives a revenue (from the marketplace), Asset Composer will distribute it to appropriate asset providers autonomously.

![](https://i.imgur.com/9ZlNoM8.png)

![](https://i.imgur.com/ddhwxA7.png)

You can see the current version of Asset Composer code [here](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/AssetComposer.sol). 

### Asset Providers (deployed)

Asset Providers are *a new category of smart contracts*, each of which provides a set of vector assets. Those assets are either stored on-chain, dynamically generated, or a combination of those.

Asset Composer acts as the registration mechanism of those asset providers so that the user can easily discover available assets when authoring new images using the On-chain Vector Editor (described below).

Each Asset Provider implements [IAssetProvider](https://github.com/Cryptocoders-wtf/generative/blob/main/contract/contracts/packages/assetProvider/IAssetProvider.sol) interface (protocol). This interface allows other smart contracts to retrieve vector assets from the asset provider. <u>It also has a payment mechanism, for autonomous marketplace</u>, such as Draw2Earn application described below.

As a reference implementation, we have created a wrapper of NounsDescriptor, [NounsAssetProvider](https://github.com/Cryptocoders-wtf/generative/blob/main/contract/contracts/NounsAssetProvider.sol), which offers dynamically generated Nouns characters as assets. 

![](https://i.imgur.com/c8ngYmT.png)

### On-Chain Canvas (beta testing)

On-Chain Canvas is a *WebUI front-end* of Asset Composer, which allows creative people to author new images by drawing and combining existing vector assets, just like Adobe Illustrator, and mint it as an NFT.

[The beta version of On-Chain Canvas](https://onchaincanvas.xyz) on Goerli network is available for the beta testing. 

![](https://i.imgur.com/lPcTuTz.png)

The source code of On-Chain Canvas is available [here](https://github.com/Cryptocoders-wtf/onchaincanvas). 

### Draw2Earn (beta testing)

During the development of the On-Chain Canvas described above, we came up with the idea to release it as a **Draw2Earn** application.

Here is the business model. 

1. Creating a new drawing from scratch and minting it as an NFT is free. The minter needs to pay only the gas fee to upload the vector data of the drawing to the blockchain. 
2. Creating a drawing using assets provided by *asset providers* and minting it as NFT is NOT free. <u>We will charge a small amount (probably 〜0.02ETH), and distribute most of it (97.5%) to the creators and minters of those assets</u> via *asset providers*.
3. If the remixed asset is a composition of multiple assets, we will distribute the payout recursively, splitting it equally at each level.

We are aware that most of the *X2Earn* services introduce their app-specific currencies, which allows developers to keep all the earnings, by paying rewards to users in the app-specific currency. 

This approach creates a so-called *token economy*, giving the developer the power to print money as the central bank of that economy.

We chose **NOT** to take that approach because it will turn the service into a *pseudo Ponzi scheme*, where the infinite growth is required to keep it attractive.

We believe the direct and immediate distribution of revenue to creators (using the *autonomous revenue sharing mechanism*) is fair to everybody and a better mechanism to create a healthy and sustainable ecosystem.

### CC-Share-Earnings (draft proposal)

During the development process of the Draw2Earn business model, we realized that we need a new kind of Creative Commons license, *CC-Share-Earnings*, which is suitable for on-chain assets (such as vector images, but not limited to them).

<u>This license allows other people to copy or remix it just like regular Creative Commons, but revenue sharing is required if somebody uses it to generate revenue</u>.

As described above, [IAssetProvider](https://github.com/Cryptocoders-wtf/generative/blob/main/contract/contracts/packages/assetProvider/IAssetProvider.sol) interface has a built-in revenue-sharing mechanism (*processPayout* method), and <u>it allows us to create **autonomous marketplace** to buy and sell vector assets</u>. 

We'd like to propose it as the standard mechanism to share revenue for various on-chain contents (not only images, but music and videos eventually).

### Generative Asset Providers (deployed)

As described in the Asset Provider section, any smart contract, which supports [IAssetProvider](https://github.com/Cryptocoders-wtf/generative/blob/main/contract/contracts/packages/assetProvider/IAssetProvider.sol) interface can be registered to the Asset Composer as an asset provider and start earning money.

<u>This is a new business opportunity for developers, who are interested in creating **generative arts**</u>.

In order to make it easy for developers to get into this market, we are building libraries and sample code. [SplatterProvider](https://github.com/Cryptocoders-wtf/generative/blob/main/contract/contracts/SplatterProvider.sol) is one of sample smart contracts (see below).

![](https://i.imgur.com/HVAIajb.png)

We would like to invite other developers to join this effort. If anybody is interested in it, please join the [Fully On-Chain](https://discord.gg/4JGURQujXK) discord.

We have released our first fully on-chain generative art NFT collection, [On-Chain Splatter](https://opensea.io/collection/on-chain-splatter) on October 17th, 2022, which was sold out within a few hours.

## Decentralized Autonomous Marketplace

As described above, we are designing and implementing a **decentralized autonomous marketplace (DAM)** of digital assets, where artists, remixers, crowd-minters, and developers can earn money.

![](https://i.imgur.com/Drxt6Iu.png)

Because of the high gas cost to store a large amount of data on the blockchain (Ethereum mainnet), the role this marketplace can play is limited at this moment (2022).

We, however, believe that this issue will be solved eventually, and this decentralized autonomous marketplace can play an important role to create a healthy ecosystem of on-chain digital assets.