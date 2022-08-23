# On-line Asset Store and Composer

This is the summary document, which describes the vision & mission of this project and various technologies and methods we are building. 

## Importance of being Fully On-chain

While the decentralization is one of the fundamental values of Web3, most of NFTs (including Bluechip NFTs such as Bored Ape and Azuki) are **not fully on-chain**, storing metadata and images on either HTTP server or IPFT. 

It means those NFTs will become inaccessible (you can not see their metadata or images) once the NFT providers cease to exist or simply stop supporting them. 

It means those NFTs are not really yours, and they are under the control of NFT providers, just like many Web2 services. They are more like Web 2.5 NFTs. 

On the other hand, **fully on-chain NFTs** such as Nouns are guarantteed to "exist" a hundred years from now, as long as the blockchain exists. 

It means you are the sole owner of those fully on-chain NFTs and nobody is able to take them away from you. "Fully on-chain NFT" means "decentralized NFT" -- the true Web3 spirit!

You can easily check if your NFTs are fully on-chain or not by calling tokenURI() method on Etherscan. If the URL starts with "http:" or "ipft:", they are not on-chain NFTs. The tokenURI method of a truely decentralized NFT contract will alway return "data:" URL, which is the proof that its metadata and image are stored on-chain. 

![](https://i.imgur.com/kCfzdsL.png)

## Technical Challenges

Despite such an imporance, why so many NFTs are not on-chain? The answer is simple, the gas cost to store large data on chain. There is some effots to work around this problem with generative arts, but there are many technical challenges. 

[Nouns](https://nouns.wtf) is one of a few bluechip NFTs, which are also fully on-chain. They have managed to do so, by reducing the resolution of images down to 32x32 pixels and store them as highly compressed binary data on chain. 

![](https://i.imgur.com/6BMmUQs.png)

[Cyberbrokers](https://cyberbrokers.io) is the first (and only as far as we know) project which stores rich graphics on-chain, but they needed to spend over $100,000 to upload a large set of SVG data to the blockchain.

![](https://i.imgur.com/Mp9xUwH.jpg)

[Art Blocks](https://www.artblocks.io/) is a great platform to publish generative arts, but Solidity is not an ideal platform for generative arts (yet). As the compromize, they use Javascript to generate arts off-chain, store those scripts on chain (which never run on-chain), and use an HTTP server to store metadata and generated images. 

![](https://i.imgur.com/NxissZu.png)

## Vision and Mission

Considering the current situation, we have determined to create a set of technologies and mechanisms, which will make it easier and affordable to store, share and compose vector images on-chain, enabling fully on-chain NFTs with rich graphics. 

## Our Approach

Here is the list of technologies and mechanism we are building. 

### SVG Compression

While SVG is the industry standard to exchange vector data, raw SVG data is quite verbose and not suitable as the storage format on the blockchain.

After various prototpyes, we have chosen to compress SVG data in following steps. 

1. We convert all SVG elements to "path" elements, eliminating the need to specify element types (such as "rect" and "circle").
2. We convert all floating points to integers by having a large and fixed view area (1024 x 1024).
3. We extract only the "d" attribute of those path elements, eliminating SVG tags entirely.
4. We compress a series of data (commands and their parameters) in the "d" attribute into a series of 12-bit bytecodes.
5. In this byte code, commands (such as "M" and "Q") will be simply expanded to 12-bit (higher 4-bits will be all zero), while parameters (number ranging from -1023 to 1023) will be converted to N+1024+256 (higher 4-bits will be non-zero).

We always perform this encoding off-chain (typically in TypeScript) before pass the data to the smart contract. Please see compressPath method in [createMethod.ts](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/utils/createAsset.ts). 

The decoding will be typically done on-chain in the "view" method, such as tokenURI() or generateSVGPath(). Even though there is no "gas cost" associated with it, an effient implementation is critical to avoid time-out or gas-limit errors. Please see decodePath method of [SVGPathDecoderA](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/libs/SVGPathDecoderA.sol). 

### On-Chain Asset Store

The On-chain Asset Store is a smart contract, which acts as the public on-chain asset storage service, allowing developers to store and share vector assets.

It stores various vector data in the compressed format described above, and make them available to other smart contracts, just like the asset store for Unity 3D engine. 

Please see [AssetStore.sol](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/AssetStore.sol) for details. 

### Crowd Minting

The "crowd minting" is a method to eliminate a large upfront cost for developers when issueing fully on-chain NFT collection (just like the developer of Cyberbrokers did).

Instead, developrs ask each minter pays a small extra gas fee by uploading a necessary vector data to the block chain during the minting process. 

This is done by calling mintWithAsset() method, which stores the vector data to the On-Chain Asset Store, and issue NFT(s) to the minter.

We have launched three NFT collections using the crowd minting, and managed to upload over 1,000 vector images on-chain. 

![Uploading file..._x7hrvsj55]()

Please see the mintWithAsset() method of [KamonToken.sol](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/KamonToken.sol) as the reference implementation. 

### Asset Composer

Asset Composer is a smart contract, which allows developers to create a new vector asset by composing existing vector assets, on On-Chain Asset Store, Asset Composer itself or other asset providers.

Asset Composer is still under development (not deployed yet), but you can see the current version at [here](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/AssetComposer.sol). 

### Asset Providers

Asset Providers are a set of contracts, which provides a set of vector assets. Those assets are either stored on-chain, dynamically generated, or the combination of those. 

AssetComposer acts as the registration mechanism of those asset providers, so that the user can easily discover available assets when authoring new images using the On-chain Vector Editor (desribed below).

Each Asset Provider implement [IAssetProvider](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/interfaces/IAssetComposer.sol) interface (still under development).

As a reference implementation, we have created a wrapper of NounsDescriptor, [NounsAssetProvider](https://github.com/Cryptocoders-wtf/assetstore-contract/blob/main/contracts/NounsAssetProvider.sol), which offers dynamically generated Nouns characters as assets. 

![Uploading file..._eeau882iv]()


### On-Chain Vector Editor (WebUI)

On-Chain Vector Editor is a WebUI front-end of Asset Composer, which allows creative people to author new images by drawing and combining existing vector assets, just like Adobe illustrator, and mint it as a new NFT.

On-Chain Vector Editor is still under development as a part of [WebUI front-end of On-Chain AsstStore](https://github.com/Cryptocoders-wtf/assetstore). 