const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
require("hardhat")

async function deployOneYearLockFixture() {
  const [owner, addr1, addr2] = await ethers.getSigners();

  const Token1 = await ethers.getContractFactory("Coins");
  const hardhatERC20 = await Token1.deploy(1000);

  const Token2 = await ethers.getContractFactory("Assest");
  const hardhatERC721 = await Token2.deploy();

  const Token3 = await ethers.getContractFactory("MyToken");
  const hardhatERC1155 = await Token3.deploy();

  const Token = await ethers.getContractFactory("MarketPlace");
  const hardhatMarket = await Token.deploy(hardhatERC20.address);

  return {owner ,addr1, addr2,hardhatMarket, hardhatERC20, hardhatERC721, hardhatERC1155};
}

describe("MarketPlace contract function", async function () {

  it("it should add sale for token in saleList", async function () {
    let {owner,hardhatMarket, hardhatERC721} = await loadFixture(deployOneYearLockFixture);
    await hardhatERC721.safeMint(owner.address);
    await hardhatMarket.saleForERC721(hardhatERC721.address, 0,40);
    expect((await hardhatMarket.saleList(0))[0]).to.equal(hardhatERC721.address);
    expect(parseInt((await hardhatMarket.saleList(0))[3]._hex)).to.equal(40);

  });

  it("it should sell ERC721 token to buyer", async function () {
    let {owner,addr1, hardhatMarket, hardhatERC20, hardhatERC721} = await loadFixture(deployOneYearLockFixture);
    await hardhatERC20.approve(hardhatMarket.address, 1600);
    await hardhatERC721.safeMint(addr1.address);
    await hardhatERC721.connect(addr1).approve(hardhatMarket.address, 0);
    await hardhatMarket.connect(addr1).saleForERC721(hardhatERC721.address , 0, 40);
    await hardhatMarket.buyERC721(0);
    expect(await hardhatERC20.balanceOf(addr1.address)).to.equal(40);
    expect(await hardhatERC721.ownerOf(0)).to.equal(owner.address);
    expect(await hardhatERC20.balanceOf(owner.address)).to.equal(960);
  });

  it("it should sell ERC1155 token to buyer", async function () {
    let {owner,addr1, hardhatMarket, hardhatERC20, hardhatERC1155} = await loadFixture(deployOneYearLockFixture);
    await hardhatERC20.approve(hardhatMarket.address, 400);
    await hardhatERC1155.mint(addr1.address,0,20);
    await hardhatERC1155.connect(addr1).setApprovalForAll(hardhatMarket.address, true);
    await hardhatMarket.connect(addr1).saleForERC1155(hardhatERC1155.address , 0, 40, 10);
    await hardhatMarket.buyERC1155(0,10);
    expect(await hardhatERC20.balanceOf(addr1.address)).to.equal(0);
    expect(await hardhatERC1155.balanceOf(owner.address,0)).to.equal(10);
    expect(await hardhatERC20.balanceOf(owner.address)).to.equal(960);
  });
});
