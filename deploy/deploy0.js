module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();
    await deploy('ERC20', {
      from: deployer,
      args: ['Hello', "sky", 8],
      log: true,
    });
  };
  module.exports.tags = ['ERC20'];
  