// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

contract A {
    uint256 public Add;
    uint256 public Sub;
    uint256 public intitotal;
    address public b;

    fallback(bytes calldata data) external returns (bytes memory) {
        (bool ok, bytes memory res) = b.delegatecall(data);
        require(ok, "call failed");
        return res;
    }

    constructor(address _b) {
        b = _b;
    }

    function addition(uint256 _num) external {
        intitotal += _num;
        Add = _num;
    }

    function subtraction(uint256 _num) external {
        intitotal -= _num;
        Sub = _num;
    }
}

contract B {
    uint256 public Add;
    uint256 public Sub;
    uint256 public intitotal;

    function multi(uint256 _b) external returns(uint256){
         intitotal = (Add-Sub);
         return _b;
    }
}