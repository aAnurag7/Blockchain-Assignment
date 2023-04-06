// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC721{
    
    event transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

contract Assets is IERC721{
    string private name;
    string private symbol;
    uint256 private id;
    mapping(uint256 => address) private owner;
    address public coinsContractAddress;
    
    
    struct Token{
        uint256 tokenId;
        uint256 timestamp;
    }

    mapping(address => uint256) private balance;
    mapping(uint256 => address) private tokenApprove;
    mapping(address => mapping(address => bool)) private operator;
    mapping(uint256 => uint256) private value;
    constructor(string memory _name, string memory _symbol, address _coinsContractAddress) {
        symbol = _symbol;
        name = _name;
        coinsContractAddress = _coinsContractAddress;
    }
    
    function mint() public {
        owner[++id] = msg.sender;
        balance[msg.sender]++;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balance[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return owner[_tokenId];
    }

    function approve(address _to, uint256 _tokenId) public payable {
        require(owner[_tokenId] == msg.sender, "owner has not that token");
        tokenApprove[_tokenId] = _to;
        emit Approval(owner[_tokenId], _to, _tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return tokenApprove[tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operator[_owner][_operator];
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        operator[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public  payable {
        require(owner[_tokenId] == msg.sender && (_from == msg.sender), "not approved");
        require((getApproved(_tokenId) == _to) || isApprovedForAll(owner[_tokenId], msg.sender), "no approved");
        delete tokenApprove[_tokenId];
        balance[_from]--;
        balance[_to]++;
        owner[_tokenId]=_to;
        emit transfer(_from, _to, _tokenId);
    }

    function setPrice(uint256 _price, uint256 _tokenId) public {
       require(owner[_tokenId] == msg.sender, "not approved to set price");
       value[_tokenId] = _price;
    }

    function swapToken(uint256 _tokenId) external {
       require(value[_tokenId] != 0, "price not set");
       IERC20(coinsContractAddress).transferFrom(msg.sender,owner[_tokenId], value[_tokenId]);
       balance[owner[_tokenId]]--;
       owner[_tokenId] = msg.sender;
       balance[msg.sender]++;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable {
       transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable {
       transferFrom(_from, _to, _tokenId);
    }
}