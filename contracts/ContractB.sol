// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract ContractB {
    uint256 public Add;
    uint256 public Sub;
    uint256 public initotal;

    function multi(uint256 _b) external returns(uint256){
         initotal = (Add-Sub)*_b;
         return _b;
    }
}