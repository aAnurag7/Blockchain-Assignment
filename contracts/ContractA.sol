// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract ContractA {
    uint256 public Add;
    uint256 public Sub;
    uint256 public initotal;
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
        initotal += _num;
        Add = _num;
    }

    function subtraction(uint256 _num) external {
        initotal -= _num;
        Sub = _num;
    }
}