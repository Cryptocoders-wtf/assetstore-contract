// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { IStringValidator } from '../interfaces/IStringValidator.sol';

library StringSet {
  struct Set {
    mapping(uint32 => string) names;
    uint32 nextIndex;
    mapping(string => uint32) ids; // index+1
  }

  function getId(Set storage set, string memory name, IStringValidator validator) internal returns(uint32) {
    uint32 id = set.ids[name];
    if (id == 0) {
      require(validator.validate(name), "StringSet.getId: Invalid String");
      set.names[set.nextIndex++] = name;
      id = set.nextIndex; // idex + 1
      set.ids[name] = id; 
    }
    return id;
  }
}