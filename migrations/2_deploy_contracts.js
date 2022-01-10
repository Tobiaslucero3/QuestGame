const CharacterFactory = artifacts.require("CharacterFactory");

module.exports = function (deployer) {
  deployer.deploy(CharacterFactory);
};
