// SPDX-License-Identifier: MIT

/*
 * Kamon NFT (ERC721). The mint function takes IAssetStore.AssetInfo as a parameter.
 * It registers the specified asset to the AssetStore and mint a token which represents
 * the "minter" of the asset (who paid the gas fee), along with two additional bonus tokens.
 * 
 * It uses ERC721A as the base contract, which is quite efficent to mint multiple tokens
 * with a single transaction. 
 *
 * Once minted, the asset will beome available to other smart contract developers,
 * for free, either CC0, CC-BY-SA(Attribution-ShareAlike), Appache, MIT or similar.
 * 
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "erc721a/contracts/ERC721A.sol";
import { Base64 } from 'base64-sol/base64.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import { IProxyRegistry } from './external/opensea/IProxyRegistry.sol';

contract SplatterToken is Ownable, ERC721A {
  using Strings for uint256;
  using Strings for uint16;

  uint256 constant _tokensPerAsset = 10;

  // description
  string public description = "This is one of effts to create (On-Chain Asset Store)[https://assetstore.wtf]. "
  " All kamon vectors were created and copyrighted by (Hakko Daiodo)[http://hakko-daiodo.com].";

  // developer address.
  address public developer;

  // OpenSea's Proxy Registry
  IProxyRegistry public immutable proxyRegistry;

  /**
   */
  constructor(
    address _developer,
    IProxyRegistry _proxyRegistry
  ) ERC721A("Kamon Symbols by Hakko Daiodo", "KAMON") {
    developer = _developer;
    proxyRegistry = _proxyRegistry;
  }

  function _isPrimary(uint256 _tokenId) internal pure returns(bool) {
    return _tokenId % _tokensPerAsset == 0;
  }

  /**
   */
  function mint(uint256 _affiliate) external {
    uint256 tokenId = _nextTokenId(); 
    _mint(msg.sender, _tokensPerAsset - 1);

    // Specified affliate token must be one of the primary tokens and not owned by the minter.
    if (_affiliate > 0 && _isPrimary(_affiliate) && ownerOf(_affiliate) != msg.sender) {
      _mint(ownerOf(_affiliate), 1);
    } else if ((tokenId / _tokensPerAsset) % 2 == 0) {
      // 1 in 20 tokens of non-affiliated mints go to the developer
      _mint(developer, 1);
    } else {
      // the rest goes to the owner for distribution
      _mint(owner(), 1);
    }
  }
  /*
   * @notice get next tokenId.
   */
  function getCurrentToken() external view returns (uint256) {                  
    return _nextTokenId();
  }

  /**
    * @notice Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
    */
  function isApprovedForAll(address owner, address operator) public view override returns (bool) {
      // Whitelist OpenSea proxy contract for easy trading.
      if (proxyRegistry.proxies(owner) == operator) {
          return true;
      }
      return super.isApprovedForAll(owner, operator);
  }

  string constant SVGHeader = '<svg viewBox="0 0 1024 1024'
      '"  xmlns="http://www.w3.org/2000/svg">\n'
      '<defs>\n';

  /*
   * A function of IAssetStoreToken interface.
   * It generates SVG with the specified style, using the given "SVG Part".
   */
  function generateSVG(string memory _svgPart, uint256 _style, string memory _tag) public pure returns (string memory) {
    // Constants of non-value type not yet implemented by Solidity
    string[10] memory backColors = [
      "black", "white", "#EFE8AC", "#EFE5AF", "#5B3319", "#BF2E16", "#0963AD", "#3D5943", "black", "url(#gold)" 
    ];
    string[10] memory frontColors = [
      "white", "black", "#0D95A0", "#58456B", "#EFE8AC", "#EFE8AC", "#FFFFFF", "#FFFFFF", "url(#gold)", "black"
    ];

    bytes memory assetTag = abi.encodePacked('#', _tag);
    uint index = _style % _tokensPerAsset;
    bytes memory image = abi.encodePacked(
      SVGHeader,
      _svgPart);
    if (index >= 8) {
      image = abi.encodePacked(
        image, 
        '<linearGradient id="gold" x1="0.2" x2="0" y1="0" y2="1">\n'
        '  <stop offset="0%" stop-color="#CCAB09"/>\n'
        ' <stop offset="50%" stop-color="#FFF186" />\n'
        ' <stop offset="100%" stop-color="#CCAB09"/>\n'
        '</linearGradient>\n');
    }
    image =  abi.encodePacked(
      image,
      '</defs>\n'
      ' <rect x="0" y="0" width="100%" height="100%" fill="',backColors[index],'" />\n'
      ' <use href="', assetTag, '" fill="',frontColors[index],'" />\n'
      '</svg>\n');
    return string(image);
  }

  function _generateTraits(uint256 _tokenId) internal view returns (bytes memory) {
    return abi.encodePacked(
      '{'
        '"trait_type":"Primary",'
        '"value":"', _isPrimary(_tokenId) ? 'Yes':'No', '"' 
      '}'
    );
  }

  function setDescription(string memory _description) external onlyOwner {
      description = _description;
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), 'KamonToken.tokenURI: nonexistent token');
    string memory svgPart = "xxx";
    bytes memory image = bytes(generateSVG(svgPart, _tokenId % _tokensPerAsset, "xxx"));

    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name":"', "xxx", 
                '","description":"', description, 
                '","attributes":[', _generateTraits(_tokenId), 
                '],"image":"data:image/svg+xml;base64,', 
                Base64.encode(image), 
              '"}')
          )
        )
      )
    );
  }  

  function tokensPerAsset() public pure returns(uint256) {
    return _tokensPerAsset;
  }
}
