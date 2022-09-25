// SPDX-License-Identifier: MIT

/*
 * AssetComposer allows developers to create a composition from a collection of
 * assets provided by registered asset providers.
 * 
 * IAssetComposer is the interface for the consumer of this composition service. 
 * IAssetProvider is the interface each asset provider implements.
 * IAssetProviderRegistry is the interface to register various asset providers (to AssetComposer).
 * AssetComposer implements IAssetProvider interface as well, and registers itself.  
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IStringValidator } from './interfaces/IStringValidator.sol';
import { IAssetProvider, IAssetProviderRegistry, IAssetComposer } from './interfaces/IAssetComposer.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';

contract AssetProviderRegistry is IAssetProviderRegistry, Ownable {
  uint256 nextProvider; // 0-based
  mapping(string => uint256) providerIds; // key => providerId+1
  mapping(uint256 => IAssetProvider) providers;
  mapping(uint256 => bool) disabledProvider;

  function registerProvider(IAssetProvider _provider) external override returns(uint256 providerId) {
    IAssetProvider.ProviderInfo memory providerInfo = _provider.getProviderInfo();
    providerId = providerIds[providerInfo.key];
    if (providerId != 0) {
      // Update
      providerId--; // change it to 0-based
      IAssetProvider existingProvider = providers[providerId];
      require(_provider.getOwner() == existingProvider.getOwner(), "AssetComposer:registerProvider, already registered");
      providers[providerId] = _provider;
      emit ProviderUpdated(msg.sender, providerId);
    } else {
      // New Registration
      require(_provider == providerInfo.provider, "AssetComposer:registerProvider, address mismatch");
      providers[nextProvider++] = _provider;
      providerIds[providerInfo.key] = nextProvider; // @notice: providerID + 1
      providerId = nextProvider - 1; 
      emit ProviderRegistered(msg.sender, providerId);
    }
  }

  function providerCount() external view override returns(uint256) {
    return nextProvider;
  }

  function getProvider(uint256 _providerId) public view override returns(IAssetProvider.ProviderInfo memory, bool) {
    IAssetProvider provider = providers[_providerId];
    return (provider.getProviderInfo(), disabledProvider[_providerId]);
  }

  function getProviderId(string memory _key) public view override returns(uint256) {
    uint256 idPlusOne = providerIds[_key];
    require(idPlusOne > 0, string(abi.encodePacked("AssestComposer:getProviderId, the provider does not exist:", _key)));
    return idPlusOne - 1;
  }

  address public admin;
  modifier onlyAdmin() {
    require(owner() == msg.sender || admin == msg.sender, "AssetComposer: caller is not the admin");
    _;
  }

  function setAdmin(address _admin) external onlyOwner {
    admin = _admin;
  }  

  function setDisabledProvider(uint256 _providerId, bool _status) external onlyAdmin {
    disabledProvider[_providerId] = _status;
  }
}
