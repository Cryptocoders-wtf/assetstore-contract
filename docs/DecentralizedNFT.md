# Decentralized NFT

## Major flaw of ERC721

While NFT is playing a very important role to bring more people into the Web3 ecosystem and even create new income opportunities to artists, the protocol itself, ERC721, is still very immature and has a few fundamental issues.

1. Royalities are not enforceable.
2. Many NFTs are stolen.
3. It is not decentralized.

Because royalities are not part of ERC721, it is up to the marketplaces, such as OpenSea, to pay royalities.

As the result, many royality-free were born, and [the "Race to the Bottom" has started](https://nextnftdrop.com/news/one-more-nft-marketplace-goes-royalty-free-in-the-race-to-the-bottom/).

A lot of NFTs are stolen by scam sites, which ask the user to connect his/her wallet, let him/her to call ApprovalForAll (without understanding what it means), and steal NFTs.

The fundamental flaw of ERC721 is in this "approve & transfer" model, which gives too much power to the marketplace, far from the beauty of Web3's "decetalized and trustless" model.

Once the token owner calls Approval or ApprovalForAll, the marketplace can do whater they want to do to the token (or tokens). 

This is why royality-free marketplaces were born, and so many NFTs are stoken.

In order to solve this problem, we need to create a new mechanism, which performs transactions without trusted third parties (P2P transactions), and makes it possible to enforce royalities.

## P2P/Trustless transactions

Decentralized transactions will become possible by adding three methods to ERC721.

```
interface ERC721P2P is ERC721 {
  function setPriceOf(uint256 _tokenId, uint256 _price) external;
  function getPriceOf(uint256 _tokenId) external view returns(uint256);
  function purchase(uint256 _tokenId, address _wallet) external payable;
}
```
The token owner calls *setPriceOf* method to set the asking price of a specific token he/she owns.

Anybody can access this asking price by calling the *getPriceOf* method (it returns 0, if it is not specified).

Anybody can buy it by calling the *purchase* method by paying the asking price.

The smart contract that receives this money (via *purchase* method) distributes it between the token owner and the artist, enforcing the royalty payment agreement between them.  

Please notice that this transaction happens just between the seller and the buyour, without involving any third party. Because of that, it is possible to make a trade by using Etherscan.  

This is already a huge improvement over the current "approval & transfer" mode, but we need to solve other scenario where the buyer making an offer first (or making an offer lower than the asking price).

## "Offer and Accept" scenario

There are a few possible ways to support this scenario, but I think the decentralized marketplace is the most reasonable solution.

```
interface IERC721Marketplace {
  function makeAnOffer(ERC721P2P _contract, uint256 _tokenId, uint256 _price) external payable;
  function withdrawAnOffer(ERC721P2P _contract, uint256 _tokenId) external;
  function getTheBestOffer(ERC721P2P _contract, uint256 _tokenId) external view 
      returns(uint256, address);
  function acceptOffer(ERC721P2P _contract, uint256 _tokenId, uint256 _price) external;
}

interface ERC721P2P is ERC721 {
  function setPriceOf(uint256 _tokenId, uint256 _price) external;
  function getPriceOf(uint256 _tokenId) external view returns(uint256);
  function purchase(uint256 _tokenId, address _wallet) external payable;
  function acceptOffer(uint256 _tokenId, IERC721Marketplace _dealer, uint256 _price) external;
}
```

The buyer makes an offer by calling the *makenAnOffer* method at an autonomous market place, staking the amount of money he/she is willing to pay. 

The seller (or other buyers) can see the current best offer (on that particular marketplace) by calling the *getTheBestOffer* method.

The buyer accepts this offer by calling the *acceptOffer* method of the ERC721P2P contract, which matches the asking price to the offer price, and calls the *acceptOffer* method of the specified autonomous marketplace.

The autonomous marketplace calls back the *purhase* method with the money from the buyer, and let it complete the transaction.

## ERC721 compatibility

For the smooth transition, it makes sense to make the new protocol compatible to ERC721, simply inheriting it. We, however, need to disable (or particially disable) *approval* and *approvalForAll* method, in order to prevent transactions on royalty-free marketplace.

During the transition period, it makese sense to have a whitelist of marketplaces, so that traditional "approval and transfer" style transactions can happen only on trusted marketplaces which pay royalities appropriately.

We don't need to disable the *transfer* method, which allows token owners to transfer their tokens to other wallets. We don't need to eliminate off-the-market transactions compoletely.

## Security Concerns

With this change, scam sites will attempt to let the user call the *acceptOffer* method with very low price. We certainly needs a special UI on the wallet (such as Metamask), which clearly presents the meaning of this transaction (the NFT and the offer price). 