// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Keccak256Recursive {
  bytes32 _x;
  
  constructor(bytes32 x) {
    _x = x;
  }

  function compute(uint k) public returns(bytes32) {
    if (k == 0) {
      return _x;
    } else {
      bytes memory res = new bytes(32);
      assembly {
        mstore(add(res, 32), sload(_x.slot))
      }
      
      for (uint i = 0; i < k; i++) {
        bytes32 hash;
        assembly {
          hash := keccak256(add(res, 32), 32)
        }
        assembly {
          mstore(add(res, 32), hash)
        }
      }
      
      bytes32 finalResult;
      assembly {
        finalResult := mload(add(res, 32))
      }
      
      _x = finalResult;
      return finalResult;
    }
  }
}