// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MarketPlace {

    event TransferToken(address indexed from, address indexed to, uint256 tokenId, uint256 amount);    address public MarketPlaceOwner;
    IERC20 public token;
    struct Sales{
        address contractAddress;
        uint256 tokenId;
        uint256 price;
        uint256 amount;
    } 
    mapping(uint256 =>  mapping(address => Sales)) public saleList;
    bool internal locked;

    modifier AvoidReentrancy() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    /// @notice deploy market place contract
    /// @param _ERC20Contract address of ERC20 contract
    constructor(address _ERC20Contract) {
        MarketPlaceOwner = msg.sender;
        token = IERC20(_ERC20Contract);
    }

    function Tokenbalance() external view returns(uint256){
        return token.balanceOf(address(this));
    }
    
    /// @notice create sale for ERC721 token
    /// @dev add details of sale token in saleList map
    /// @param _contractAddress The address of ERC721 contract 
    /// @param _tokenId token ID of token that will add in saleList
    /// @param _price price of token in ERC20 token
    function saleForERC721(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _price
    ) external {
        IERC721 contractErc721 = IERC721(_contractAddress);
        require(contractErc721.ownerOf(_tokenId) == msg.sender, "not have that token");
        saleList[_tokenId][msg.sender] = Sales(_contractAddress, _tokenId, _price,1);
    }

    /// @notice create sale for ERC1155 token
    /// @dev add details of sale token in saleList map
    /// @param _contractAddress The address of ERC1155 contract 
    /// @param _amount The amount of tokens that will add in saleList
    /// @param _tokenId token ID of token that will add in saleList
    /// @param _price price of token in ERC20 token
    function saleForERC1155(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount
    ) external {
        IERC1155 contractErc1155 = IERC1155(_contractAddress);
        require(contractErc1155.balanceOf(msg.sender,_tokenId) >= _amount, "not have that token");
        saleList[_tokenId][msg.sender] = Sales(_contractAddress, _tokenId, _price, _amount);
    }

    /// @notice create buy for ERC721 token
    /// @dev send sale token to msg.sender and recieve payment in terms of eth or ERC20 token
    /// @param _tokenId token ID of token that will add in saleList
    function buyERC721(uint256 _tokenId, address _owner) public payable AvoidReentrancy {
        IERC721 contractErc721 = IERC721(saleList[_tokenId][_owner].contractAddress);
        contractErc721.transferFrom(_owner, msg.sender, _tokenId);

        if(msg.value == 0) {
            uint256 TotalAmount = saleList[_tokenId][_owner].price;
            uint256 Fees = (55*TotalAmount)/10000;
            uint256 remainAmount = TotalAmount - Fees;
            token.transferFrom(msg.sender, _owner, remainAmount);
            token.transferFrom(msg.sender, address(this), Fees);
        }
        else {
            uint256 remainingAmount = msg.value - (55*msg.value)/10000;
            (bool sent, ) = _owner.call{value: remainingAmount}("");
            require(sent, "fail to send");
        }
        delete saleList[_tokenId][_owner];
        emit TransferToken(msg.sender, _owner, _tokenId,1);
    }

    /// @notice create buy for ERC1155 token
    /// @dev send sale token to msg.sender and recieve payment in terms of eth or ERC20 token
    /// @param _tokenId token Id of token that will send to msg.sender
    /// @param _amount amount of token that will send to msg.sender
    function buyERC1155(uint256 _tokenId, uint256 _amount, address _owner) public payable AvoidReentrancy {
        require(_amount <= saleList[_tokenId][_owner].amount, "amount must be less than selling token amount");
        IERC1155 contractErc1155 = IERC1155(saleList[_tokenId][_owner].contractAddress);
        saleList[_tokenId][_owner].amount -= _amount;
        contractErc1155.safeTransferFrom(_owner, msg.sender, _tokenId, _amount,"");

        if(msg.value == 0) {
            uint TotalAmount = (saleList[_tokenId][_owner].price)*(saleList[_tokenId][_owner].amount);
            uint256 Fees = (55*TotalAmount)/10000;
            token.transferFrom(msg.sender, _owner, (TotalAmount - Fees));
            token.transferFrom(msg.sender, address(this), Fees);
        }
        else {
            uint256 remainingAmount = msg.value - (55*msg.value)/10000;
            (bool sent, ) = _owner.call{value: remainingAmount}("");
            require(sent, "fail to send");
        }
        if(saleList[_tokenId][_owner].amount == 0){
            delete saleList[_tokenId][_owner];
        }
        emit TransferToken(msg.sender, _owner, _tokenId,_amount);
    }


    /// @notice create  withdraw for market place owner
    /// @dev transfer eth and token to owner
    function withDraw() external payable{
        require(MarketPlaceOwner == msg.sender, "not authorized");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "fail to withdraw");
        uint256 amount = token.balanceOf(address(this));
        token.transfer(msg.sender, amount);
    }
}