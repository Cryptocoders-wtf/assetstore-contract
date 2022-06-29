// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { IStringValidator } from '../interfaces/IStringValidator.sol';

/*
 * StringSet stores a set of names (or either group or catalog in AssetStore). 
 */
library StringSet {
  struct Set {
    mapping(uint32 => string) names;
    uint32 nextIndex;
    mapping(string => uint32) ids; // index+1
  }

  /*
   * Returns the id (index + 1) of the specified name, adding it to the data set if necessary.
   * @notice: We vaildates it when we add it to the data set. 
   */
  function getId(Set storage set, string memory name, IStringValidator validator) internal returns(uint32) {
    uint32 id = set.ids[name];
    if (id == 0) {
      require(validator.validate(bytes(name)), "StringSet.getId: Invalid String");
      set.names[set.nextIndex++] = name;
      id = set.nextIndex; // idex + 1
      set.ids[name] = id; 
    }
    return id;
  }

  /*
   * Safe method to access the name with its index
   */
  function nameAtIndex(Set storage _set, uint32 _index) internal view returns(string memory) {
    require(_index < _set.nextIndex, "StringSet.nameAtIndex: The index is out of range");
    return _set.names[_index];
  }
}