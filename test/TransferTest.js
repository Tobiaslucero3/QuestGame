const CharacterEquip = artifacts.require("CharacterEquip");
const Armor = artifacts.require("Armor");
const GameItem = artifacts.require("GameItem");
const utils = require("./helpers/utils");
const time = require("./helpers/time");

var expect = require('chai').expect;

const characterNames = ["Char 1", "Char 2"];

contract("CharacterEquip, ", (accounts) => {
    
    let [alice, bob] = accounts;
    let char, arm, ite;

    beforeEach(async () => {
        char = await CharacterEquip.deployed();
        arm = await Armor.deployed();
        ite = await GameItem.deployed();
        await ite.setCharacterContractAddress(char.address);
        await ite.setArmorContractAddress(arm.address);
        await arm.setItemContractAddress(ite.address);
        await arm.setCharacterContractAddress(char.address);
        await char.setArmorContractAddress(arm.address);
        await char.setItemContractAddress(ite.address);

        
    
    });

    it("Should be able to transfer a character", async () => {
        await char.createInitialCharacter('Zeus');
        await char.safeTransferFrom(alice, bob, 0);
        
    });

    it("Should not be able to transfer a character with armor equipped", asnyc () => {
        await char.createInitialCharacter('Zeus');
        await ite.mint(alice, 1);
        await arm.createArmorEntry(00);
        await char.equipWearable(0,1,1,true);
        await utils.shouldThrow( await char.safeTransferFrom(alice, bob, 0));

    });
    
    it("Should be able to transfer a character with armor equipped", asnyc () => {
        await char.createInitialCharacter('Zeus');
        await ite.mint(alice, 1);
        await arm.createArmorEntry(00);
        await char.equipWearable(0,1,1,true);
        await utils.shouldThrow( await char.safeTransferFrom(alice, bob, 0));

    });

});
