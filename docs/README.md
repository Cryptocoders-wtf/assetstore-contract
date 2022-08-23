# On-line Asset Store and Composer

This is the summary document, which describes the vision & mission of this project and various efforts we are making. 

## Importance of being Fully On-chain

While the decentralization is one of the fundamental values of Web3, most of NFTs (including Bluechip NFTs such as Bored Ape and Azuki) are not fully on chain, storing metadata and images on either HTTP server or IPFT. 

It means those NFTs will become inaccessible (you can not see their metadata or images) once the NFT providers cease to exist or simply stop supporting them. 

It means NFTs are not really yours, and NFTs are under the control of NFT providers, just like many Web2 services. We should probably call them Web 2.5 NFTs. 

On the other hand, fully on-chain NFTs such as Nouns are guarantteed to "exist" a hundred years from now, as long as the blockchain exists. 

It means you are the sole owner of those fully on-chain NFTs and nobody is able to take them away from you. "Fully on-chain NFT" means "decentralized NFT" -- the true Web3 spirit!

You can easily check if your NFTs are fully on-chain or not by calling tokenURI() method on Etherscan. If the URL starts with "http:" or "ipft:", they are not on-chain NFTs. The tokenURI method of a truely decentralized NFT contract will alway return "data:" URL, which is the proof that its metadata and image are stored on-chain. 

![](https://i.imgur.com/kCfzdsL.png)

## Technical Challenges

Despite such an imporance, why so many NFTs are not on-chain? The answer is simple, the gas cost to store large data on chain. There is some effots to work around this problem with generative arts, but they are many technical challenges. 

[Nouns](https://nouns.wtf) is one of a few bluechip NFTs, which are also fully on-chain. They have managed to do so, by reducing the resolution of images down to 32x32 pixels and store them as highly compressed binary data on chain. 

![](https://i.imgur.com/6BMmUQs.png)

[Cyberbrokers](https://cyberbrokers.io) is one of a few fully on-chain NFT projects with rich graphics, but they needed to spend over $100,000 to upload a large set of SVG data to the blockchain (Ethereum mainnet).

![](https://i.imgur.com/Mp9xUwH.jpg)

[Art Blocks](https://www.artblocks.io/) is a great platform to publish generative arts, but Solidity is not an ideal platform for generative arts (yet). As the compromize, they use Javascript to generate arts, store those scripts on chain, but use an HTTP server to store metadata and generated images. 

![](https://i.imgur.com/NxissZu.png)

## Vision and Mission

## Our Approach

### SVG Compression

### Crowd Minting

### Asset Store

### Asset Composer

### Asset Provider

### Visual Editor/Composer (WebUI)