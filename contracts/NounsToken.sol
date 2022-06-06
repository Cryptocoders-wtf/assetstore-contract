// SPDX-License-Identifier: GPL-3.0

/// @title The Nouns ERC-721 token

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { ERC721Checkpointable } from './base/ERC721Checkpointable.sol';
import { INounsDescriptor } from './interfaces/INounsDescriptor.sol';
import { INounsSeeder } from './interfaces/INounsSeeder.sol';
import { INounsToken } from './interfaces/INounsToken.sol';
import { ERC721 } from './base/ERC721.sol';
import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import { IProxyRegistry } from './external/opensea/IProxyRegistry.sol';
import "@openzeppelin/contracts/utils/Strings.sol";


contract NounsToken is INounsToken, Ownable, ERC721Checkpointable {
    using Strings for uint256;

    // nouns fes committee address.
    address public committee;
    
    // The Nouns token URI descriptor
    INounsDescriptor public descriptor;

    // The Nouns token seeder
    INounsSeeder public seeder;

    // The noun seeds
    mapping(uint256 => INounsSeeder.Seed) public seeds;

    // The internal noun ID tracker
    uint256 private _currentNounId;

    // The previous mint time
    uint256 public mintTime;
    
    // Seed data to calculate price
    struct PriceSeed {
        uint256 maxPrice;
        uint256 minPrice;
        uint256 priceDelta;
        uint256 timeDelta;
        uint256 expirationTime;
    }

    // price seed
    PriceSeed public priceSeed;

    // developer address.
    address public developer;
    
    // Mapping from token ID to price
    mapping(uint256 => uint256) private prices;
    
    // OpenSea's Proxy Registry
    IProxyRegistry public immutable proxyRegistry;

    constructor(
        INounsDescriptor _descriptor,
        INounsSeeder _seeder,
        address _developer,
        address _committee,
        PriceSeed memory _priceSeed,
        IProxyRegistry _proxyRegistry
    ) ERC721('Nouns love', 'NOUN') {
        descriptor = _descriptor;
        seeder = _seeder;
        developer = _developer;
        committee = _committee;
        proxyRegistry = _proxyRegistry;

        priceSeed.maxPrice = _priceSeed.maxPrice;
        priceSeed.minPrice = _priceSeed.minPrice;
        priceSeed.priceDelta = _priceSeed.priceDelta;
        priceSeed.timeDelta = _priceSeed.timeDelta;
        priceSeed.expirationTime = _priceSeed.expirationTime;

        mint();
    }

    /**
     * @notice Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator) public view override(IERC721, ERC721) returns (bool) {
        // Whitelist OpenSea proxy contract for easy trading.
        if (proxyRegistry.proxies(owner) == operator) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }

    /**
     * @notice Mint first Noun to the owner,
     * @dev Call _mintTo with the to address(es).
     */
    function mint() public override onlyOwner returns (uint256) {
        require(_currentNounId == 0, 'First mint only'); 
        _mintTo(owner(), _currentNounId++);
        setMintTime();
        return _mintTo(address(this), _currentNounId++);
    }
    /*
     * @notice
     * Buy noun and mint new noun along with a possible developer reward Noun.
     * Developer reward Nouns are minted every 10 Nouns.
     * @dev Call _mintTo with the to address(es).
     */
    function buy(uint256 tokenId) external payable returns (uint256) {
        address from = ownerOf(tokenId);
        address to = msg.sender;
        uint256 currentPrice = price();
        require(from == address(this), 'Owner is not the contract');
        require(tokenId == (_currentNounId - 1), 'Not latest Noun');
        require(msg.value >= currentPrice, 'Must send at least currentPrice');

        prices[tokenId] = msg.value;
        buyTransfer(to, tokenId);
        
        emit NounBought(tokenId, to);
        return _mintNext(address(this));
    }
    /*
     * @notice set previous mint time.
     */
    function setMintTime() private {
        mintTime = block.timestamp;
        emit MintTimeUpdated(mintTime);
    }
    /*
     * @notice get next tokenId.
     */
    function getCurrentToken() external view returns (uint256) {                  
        return _currentNounId;
    }
    /*
     * @notice get previous mint time.
     */
    function getMintTime() external view returns (uint256) {                  
        return mintTime;
    }
    /*
     * @notice maxPrice - (time diff / time step) * price step
     */
    function price() private view returns (uint256) {
        uint256 timeDiff = block.timestamp - mintTime;
        if (timeDiff < priceSeed.timeDelta ) {
            return priceSeed.maxPrice;
        }
        uint256 priceDiff = uint256(timeDiff / priceSeed.timeDelta) * priceSeed.priceDelta;
        if (priceDiff >= priceSeed.maxPrice - priceSeed.minPrice) {
            return priceSeed.minPrice;
        }
        return priceSeed.maxPrice - priceDiff;
    }
    /*
     * @notice anyone can burn a noun after expiration time.
     */
    function burnExpiredToken() public {
        uint256 timeDiff = block.timestamp - mintTime;
        if (timeDiff > priceSeed.expirationTime) {
            burn(_currentNounId - 1);
        }
        _mintNext(address(this));
    }
    
    /**
     * @notice Burn a noun.
     */
    function burn(uint256 nounId) public override onlyOwner {
        require(_exists(nounId), 'NounsToken: URI query for nonexistent token');
        if (_currentNounId - 1 == nounId) {
            _mintNext(address(this));
        }
        _burn(nounId);
        emit NounBurned(nounId);
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), 'NounsToken: URI query for nonexistent token');
        return dataURI(tokenId);
    }

    /**
     * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
     * with the JSON contents directly inlined.
     */
    function dataURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), 'NounsToken: URI query for nonexistent token');

        string memory nounId = tokenId.toString();
        string memory name = string(abi.encodePacked('Noun lover ', nounId));
        string memory description = string(abi.encodePacked('Noun lover ', nounId, ' is a fun of the Nouns DAO and Nouns Art Festival'));

        return descriptor.genericDataURI(name, description, seeds[tokenId]);
        // return descriptor.dataURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Set the nouns fes committee.
     * @dev Only callable by the owner.
     */
    function setCommittee(address _committee) external onlyOwner {
        committee = _committee;
    }
    function _mintNext(address to) internal returns (uint256) {
        if (_currentNounId % 10 == 0) {
            _mintTo(developer, _currentNounId++);
        }
        setMintTime();
        return _mintTo(to, _currentNounId++);
    }
    /**
     * @notice Mint a Noun with `nounId` to the provided `to` address.
     */
    function _mintTo(address to, uint256 nounId) internal returns (uint256) {
        INounsSeeder.Seed memory seed = seeds[nounId] = seeder.generateSeed(nounId, descriptor);

        _mint(owner(), to, nounId);
        emit NounCreated(nounId, seed);

        return nounId;
    }

    /**
     * @notice Transfer eth to committee.
     * @dev Only callable by the Owner.
     */
    function transfer() external onlyOwner {
        address payable payableTo = payable(committee);
        payableTo.transfer(address(this).balance);
    }

    /**
     * @notice Set Price Data.
     * @dev Only callable by the Owner.
     */
    function setPriceData(PriceSeed memory _priceSeed) external onlyOwner {
        require(_priceSeed.maxPrice > _priceSeed.minPrice, 'Max price must be larger than Min Price');
        priceSeed.maxPrice = _priceSeed.maxPrice;
        priceSeed.minPrice = _priceSeed.minPrice;
        priceSeed.priceDelta = _priceSeed.priceDelta;
        priceSeed.timeDelta = _priceSeed.timeDelta;
        priceSeed.expirationTime = _priceSeed.expirationTime;
    }

    /**
     * @notice Get Price Data. 
     */
    function getPriceData() public view returns (PriceSeed memory) {
        return priceSeed;
    }
    /**
     * @notice Get the price of token.
     */
    function tokenPrice(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), 'NounsToken: URI query for nonexistent token');
        return prices[tokenId];
    }
    
    /**
     * @notice Set developer.
     * @dev Only callable by the Owner.
     */
    function setDeveloper(address _developer) external onlyOwner {
        developer = _developer;
    }

}
