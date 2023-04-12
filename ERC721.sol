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
    mapping(address => uint256) private balance;
    mapping(uint256 => address) private tokenApprove;
    mapping(address => mapping(address => bool)) private operator;
    mapping(uint256 => uint256) private value;

    /// @notice deploy Assets contract
    /// @param _name name of ERC721 contract
    /// @param _symbol symbol of ERC721 contract
    /// @param _ERC20Contract address of ERC20 contract
    constructor(string memory _name, string memory _symbol, address _coinsContractAddress) {
        symbol = _symbol;
        name = _name;
        coinsContractAddress = _coinsContractAddress;
    }

    /// @notice create token at message sender
    /// @dev add new token token msg.sender
    function mint() external {
        owner[++id] = msg.sender;
        balance[msg.sender]++;
        emit transfer(address(0), msg.sender, id);
    }

    /// @notice tells balance of owner
    /// @return balance of owner
    function balanceOf(address _owner) external view returns (uint256) {
        return balance[_owner];
    }

    /// @notice tells owner of token ID
    /// @return owner of tokenID
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return owner[_tokenId];
    }

    /// @notice give token approval
    /// @dev approve _to to operate on tokenId
    /// Emits Arroval event 
    function approve(address _to, uint256 _tokenId) external payable {
        require(owner[_tokenId] == msg.sender, "owner has not that token");
        tokenApprove[_tokenId] = _to;
        emit Approval(owner[_tokenId], _to, _tokenId);
    }

    /// @notice tells approved address of tokenId
    /// @return approved address of tokenId
    function getApproved(uint256 tokenId) public view returns (address) {
        return tokenApprove[tokenId];
    }

    /// @notice tells is _operator approved for all token of _owner to operate
    /// @return bool
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operator[_owner][_operator];
    }

    /// @notice set approval for all token of owner
    /// @dev approve _operator to operate on all token of owner
    /// Emits ArrovalForAll event 
    function setApprovalForAll(address _operator, bool _approved) external {
        operator[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /// @dev Transfers `tokenId` from `_from` to `_to`
    /// Emits transfer event
    function transferFrom(address _from, address _to, uint256 _tokenId) external  payable {
        require(_to != address(0), "transfer to the zero address");
        require(owner[_tokenId] == _from, "transfer from incorrect owner");
        require((_from == msg.sender) || (tokenApprove[tokenId]== _to) || operator[owner[_tokenId]][msg.sender], "no approved");
        delete tokenApprove[_tokenId];
        balance[_from]--;
        balance[_to]++;
        owner[_tokenId]=_to;
        emit transfer(_from, _to, _tokenId);
    }

    /// @dev set price of _tokenId in terms of ERC20 token
    function setPrice(uint256 _price, uint256 _tokenId) external {
       require(owner[_tokenId] == msg.sender, "not approved to set price");
       value[_tokenId] = _price;
    }

    /// @dev swap token from msg.sender to _tokenId owner
    function swapToken(uint256 _tokenId) external {
       require(value[_tokenId] != 0, "price not set");
       IERC20(coinsContractAddress).transferFrom(msg.sender,owner[_tokenId], value[_tokenId]);
       balance[owner[_tokenId]]--;
       owner[_tokenId] = msg.sender;
       balance[msg.sender]++;
       emit transfer(owner[_tokenId], msg.sender, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable {
       safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable {
       transferFrom(_from, _to, _tokenId);
    }
}