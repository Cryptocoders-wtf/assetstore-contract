# Decentralized NFT

While NFT is playing a very important role to bring more people into the Web3 ecosystem and create new income opportunities to artists, the protocol itself, ERC721, is still very immature and has a few fundamental issues.

1. Royalities are not enforceable.
2. Many NFTs are stolen.
3. It is not decentralized.

Because royalities are not part of ERC721, it is up to the marketplaces, such as OpenSea, to pay royalities.

As the result, many royality-free were born, and [the "Race to the Bottom" has started](https://nextnftdrop.com/news/one-more-nft-marketplace-goes-royalty-free-in-the-race-to-the-bottom/).

A lot of NFTs are stolen by scam sites, which ask the user to connect his/her wallet, let him/her to call ApprovalForAll (without understanding what it means), and steal all the NFTs.

The fundamental flaw of ERC721 is in this "approve & transfer" model, which gives too much power to the marketplace, far from the beauty of Web3's "decetalized and trustless" model.

Once the token owner calls Approval or ApprovalForAll, the marketplace can do whater they want to do to the token (or tokens). 

This is why royality-free marketplaces were born, and so many NFTs are stoken.