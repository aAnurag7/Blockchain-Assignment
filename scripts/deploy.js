const hre = require("hardhat");

async function main() {

  const b = await hre.ethers.getContractFactory("ContractB");
  const B = await b.deploy();
  const a = await hre.ethers.getContractFactory("ContractA");
  const A = await a.deploy(B.address);

  await lock.deployed();

  console.log(
    `deployed to ${A.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
