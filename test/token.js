const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

async function deployOneYearLockFixture() {
  const [owner, addr1, addr2] = await ethers.getSigners();
  const Token = await ethers.getContractFactory("ERC20");
  const hardhatToken = await Token.deploy("SKY", "ERC", 8);
  return { owner , addr1,addr2, Token, hardhatToken };
}
describe("Token contract function", async function () {

  it("Deployment should assign name of tokens", async function () {
    const {hardhatToken } = await loadFixture(deployOneYearLockFixture);
    expect(await hardhatToken.getSymbol()).to.equal("SKY");
  });

  it("Deployment should assign symbol of tokens", async function () {
    const {hardhatToken } = await loadFixture(deployOneYearLockFixture);
    expect(await hardhatToken.getName()).to.equal("ERC");
  });

  it("Deployment should assign 1000 total supply of tokens", async function () {
    const {hardhatToken } = await loadFixture(deployOneYearLockFixture);
    expect(await hardhatToken.totalSupply()).to.equal(1000);
  });

  it("balanceOf function should return owner balance equal to total supply", async function () {
    const {owner ,hardhatToken} = await loadFixture(deployOneYearLockFixture);
    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Transfer function should transfer token to address", async function () {
    const {owner, addr1, hardhatToken } = await loadFixture(deployOneYearLockFixture);
    const ownerBalance = await hardhatToken.transfer(addr1.address, 100);
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(900)
    expect(await hardhatToken.balanceOf(addr1.address)).to.equal(100);
  });

  it("allowance function return approved amount of token of spender", async function (){
    const {owner, addr1, hardhatToken} = await loadFixture(deployOneYearLockFixture);
    await hardhatToken.approve(addr1.address, 50);
    expect(await hardhatToken.allowance(owner.address,addr1.address)).to.equal(50);
  })

  it("approve function allow approval token of value from address", async function () {
    const {owner, addr1, hardhatToken } = await loadFixture(deployOneYearLockFixture);
    await hardhatToken.approve(addr1.address, 100);
    expect(await hardhatToken.allowance(owner.address,addr1.address)).to.equal(100);
  });

  it("transferFrom function allow to send token from address to another address", async function () {
    const {owner, addr1,addr2, hardhatToken } = await loadFixture(deployOneYearLockFixture);
    await hardhatToken.approve(addr1.address, 100);
    await hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, 40)
    expect(await hardhatToken.allowance(owner.address,addr1.address)).to.equal(60);
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(960);
    expect(await hardhatToken.balanceOf(addr2.address)).to.equal(40);
  });

  it("mint function create token to in account", async function (){
    const {owner, addr1, hardhatToken } = await loadFixture(deployOneYearLockFixture);
    let beforeMint = await hardhatToken.balanceOf(addr1.address);
    await hardhatToken.mint(addr1.address, 100);
    expect(await hardhatToken.totalSupply()).to.equal(1100);
    let afterMint = await hardhatToken.balanceOf(addr1.address);
    expect(afterMint - beforeMint).to.equal(100);
  })
});
describe("Token contract event", async function () {

  it("Should emit Transfer event when transfer from owner account", async function () {
    const {owner, addr1, hardhatToken } = await loadFixture(deployOneYearLockFixture);
    expect(await hardhatToken.transfer(addr1.address, 50)).to.emit().withArgs(owner, addr1.address, 50);
  });

  it("Should emit Transfer event when transfer from another account", async function () {
    const {owner, addr1, addr2,hardhatToken } =  await loadFixture(deployOneYearLockFixture);
    expect(hardhatToken.transferFrom(addr1.address, addr2.address,50)).to.emit().withArgs(addr1.address,addr2.address, 50);
  });

  it("Transfer emit Should fail if sender doesn't have enough tokens", async function () {
    const {owner, addr1, addr2,hardhatToken } =  await loadFixture(deployOneYearLockFixture);
    const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);
    await expect(hardhatToken.transfer(addr1.address, 10000)).to.be.revertedWith("not enough token");
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(initialOwnerBalance);
  });

  it("Should emit Approval event when transfer from another account", async function () {
    const {owner, addr1, addr2,hardhatToken } =  await loadFixture(deployOneYearLockFixture);
    expect(hardhatToken.connect(addr1).approve(addr1.address,50)).to.emit().withArgs(addr1.address, 50);
  });

  it("Approval event Should fail if sender doesn't have enough tokens", async function () {
    const {owner, addr1,hardhatToken } = await loadFixture(deployOneYearLockFixture);
    const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);
    await expect(hardhatToken.approve(addr1.address, 10000)).to.be.revertedWith("not enough token");
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(initialOwnerBalance);
  });
});