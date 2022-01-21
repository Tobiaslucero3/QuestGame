const Character = artifacts.require("CharacterEquip");
const Armor = artifacts.require("Armor");
const Item = artifacts.require("GameItem");
const SkillLibrary = artifacts.require("SkillLibrary");
const ArmorLibrary = artifacts.require("ArmorLibrary");

module.exports = function (deployer) {
  deployer.deploy(SkillLibrary);
  deployer.link(SkillLibrary, [Character]);
  deployer.deploy(Character);
  deployer.deploy(ArmorLibrary);
  deployer.link(ArmorLibrary, [Armor]);
  deployer.deploy(Armor);
  deployer.deploy(Item);
};
