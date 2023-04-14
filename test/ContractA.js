const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Fallback', () => {
  let deployer;
  let demoContract;
    
  before(async () => {
    [deployer] = await ethers.getSigners();
    const b = await ethers.getContractFactory('ContractB');
    B = await b.deploy()
    const factory = await ethers.getContractFactory('ContractA');
    demoContract = await factory.deploy(B.address).then((res) => res.deployed());
  });

  it('should invoke the fallback function', async () => {
    await demoContract.addition(3);
    expect(await demoContract.Add()).to.equal(3);
    await demoContract.subtraction(1);
    expect(await demoContract.Sub()).to.equal(1);
    const nonExistentFuncSignature = 'multi(uint256)';
    const fakeDemoContract = new ethers.Contract(
      demoContract.address,
      [
        ...demoContract.interface.fragments,
        `function ${nonExistentFuncSignature}`,
      ],
      deployer,
    );
    const tx = fakeDemoContract[nonExistentFuncSignature](8, {gasLimit: 300000});
    await expect(tx);
    expect(await demoContract.initotal()).to.equal(16);
  });

  it('should add to initotal', async () => {
    await demoContract.addition(3);
    expect(await demoContract.Add()).to.equal(3);
  });

  it('should subtract to initotal', async () => {
    await demoContract.addition(3);
    expect(await demoContract.Add()).to.equal(3);
  });

  it('should revert on failed call', async () => {
    await demoContract.addition(3);
    expect(await demoContract.Add()).to.equal(3);
    await demoContract.subtraction(1);
    expect(await demoContract.Sub()).to.equal(1);
    const nonExistentFuncSignature = 'nonex(uint256)';
    const fakeDemoContract = new ethers.Contract(
      demoContract.address,
      [
        ...demoContract.interface.fragments,
        `function ${nonExistentFuncSignature}`,
      ],
      deployer,
    );
    const tx = fakeDemoContract[nonExistentFuncSignature](8, {gasLimit: 300000});
    await expect(tx).to.revertedWith("call failed");
  });
});
