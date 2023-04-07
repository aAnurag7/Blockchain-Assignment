// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "./Coins.sol";
import {IERC721} from "./Assest.sol";
import {IERC1155} from "./MyToken.sol";

contract MarketPlace {
    
    address MarketPlaceOwner;
    struct Sales{
        address contractAddress;
        address owner;
        uint256 tokenId;
        uint256 price;
        uint256 amount;
        address ERC20Contract;
    }
    
    mapping(uint256 => Sales) public saleList;
     
    constructor() {
        MarketPlaceOwner = msg.sender;
    }

    function saleForERC721(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _price,
        address _ERC20Contract
    ) external {
        IERC721 contractErc721 = IERC721(_contractAddress);
        require(contractErc721.ownerOf(_tokenId) == msg.sender, "not have that token");
        saleList[_tokenId] = Sales(_contractAddress,msg.sender, _tokenId, _price,1,_ERC20Contract);
    }
    function saleForERC1155(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount,
        address _ERC20Contract
    ) external {
        IERC1155 contractErc1155 = IERC1155(_contractAddress);
        require(contractErc1155.balanceOf(msg.sender,_tokenId) > _amount, "not have that token");
        saleList[_tokenId] = Sales(_contractAddress,msg.sender, _tokenId, _price, _amount, _ERC20Contract);
    }

    function buyERC721(uint256 _tokenId) public payable{
        IERC721 contractErc721 = IERC721(saleList[_tokenId].contractAddress);
        address ownerErc721Token = saleList[_tokenId].owner;
        contractErc721.transferFrom(ownerErc721Token, msg.sender, _tokenId);

        if(saleList[_tokenId].ERC20Contract != address(0)) {
            IERC20 token = IERC20(saleList[_tokenId].ERC20Contract);
            uint256 amount = saleList[_tokenId].price;
            uint256 amountFees = (55*amount)/10000;
            token.transferFrom(msg.sender, ownerErc721Token, (amount -(55*amount)/10000));
            token.transferFrom(msg.sender, address(this), amountFees);
        }
        else {
            uint256 remainingAmount = msg.value - (55*msg.value)/10000;
            (bool sent, ) = ownerErc721Token.call{value: remainingAmount}("");
            require(sent, "fail to send");
        }
    }

    function buyERC1155(uint256 _tokenId, uint256 _amount) public payable{
        IERC1155 contractErc1155 = IERC1155(saleList[_tokenId].contractAddress);
        address ownerErc1155Token = saleList[_tokenId].owner;
        contractErc1155.safeTransferFrom(ownerErc1155Token, msg.sender, _tokenId, _amount,"");

        if(saleList[_tokenId].ERC20Contract != address(0)) {
            IERC20 token = IERC20(saleList[_tokenId].ERC20Contract);
            uint amount = saleList[_tokenId].price;
            uint256 amountFees = (55*amount)/10000;
            token.transferFrom(msg.sender, ownerErc1155Token, (amount -(55*amount)/10000));
            token.transferFrom(msg.sender, address(this), amountFees);
        }
        else {
            uint256 remainingAmount = msg.value - (55*msg.value)/10000;
            (bool sent, ) = ownerErc1155Token.call{value: remainingAmount}("");
            require(sent, "fail to send");
        }
    }

}