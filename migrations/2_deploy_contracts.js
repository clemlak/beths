const Beths = artifacts.require("BethsPayout");

module.exports = function(deployer) {
  deployer.deploy(Beths);
};
