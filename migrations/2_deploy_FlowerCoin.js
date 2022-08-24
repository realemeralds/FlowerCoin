const FlowerCoin = artifacts.require("FlowerCoin.sol");

module.exports = function (depployer) {
  depployer.deploy(FlowerCoin);
};
