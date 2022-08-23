# On-line Asset Store and Composer

This is the summary document, which describes the vision & mission of this project and various efforts we are making. 

## Importance of being Fully On-chain

While the decentralization is one of the fundamental values of Web3, most of NFTs (including Bluechip NFTs such as Bored Ape and Azuki) are not fully on chain, storing metadata and images on either HTTP server or IPFT. 

It means those NFTs will become inaccessible (you can not see their metadata or images) once the NFT providers cease to exist or simply stop supporting them. 

It means NFTs are not really yours, and NFTs are under the control of NFT providers, just like many Web2 services. We should probably call them Web 2.5 NFTs. 

On the other hand, fully on-chain NFTs such as Nouns are guarantteed to "exist" a hundred years from now, as long as the blockchain exists. 

It means you are the sole owner of those fully on-chain NFTs and nobody is able to take them away from you. "Fully on-chain NFT" means "decentralized NFT" -- the true Web3 spirit!

You can easily check if your NFTs are fully on-chain or not by calling tokenURI() method on Etherscan. If the URL starts with "http:" or "ipft:", they are not on-chain NFTs. The tokenURI method of a truely decentralized NFT contract will alway return "data:" URL, which is the proof that its metadata and image are stored on-chain. 

## Technical Challenges

Despite such an imporance, why so many NFTs are not on-chain? The answer is simple, the gas cost to store large data on chain. 

[Nouns](https://nouns.wtf) is one of a few bluechip NFTs, which are also fully on-chain. They have managed to do so, by reducing the resolution of images down to 32x32 pixels and store them as highly compressed binary data on chain. 

[Cyberbrokers](https://cyberbrokers.io) is one of a few fully on-chain NFT projects with rich graphics, but they needed to spend over $100,000 to upload a large set of SVG data to the blockchain (Ethereum mainnet).

## Vision and Mission

## Our Approach

### SVG Compression

### Crowd Minting

### Asset Store

### Asset Composer

### Asset Provider

### Visual Editor/Composer (WebUI)