module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();
    await deploy('Coins', {
      from: deployer,
      args: [1000],
      log: true,
    });
  };
  module.exports.tags = ['Coins'];
