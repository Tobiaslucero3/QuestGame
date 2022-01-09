const CharacterContract = artifacts.require("CharacterContract");

module.exports = function (deployer) {
  deployer.deploy(CharacterContract);
};
