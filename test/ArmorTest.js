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

        await char.createInitialCharacter('Zeus');
        await char.createArmorEntry(0);

        await ite.mint(alice, 1);
        await ite.mint(alice, 2);
        await ite.mint(alice, 3);
        await ite.mint(alice, 4);
        await ite.mint(alice, 5);
        await ite.mint(alice, 6);
        await ite.mint(alice, 7);

        await char.equipWearable(0,1,1,true);
        await char.equipWearable(0,2,2,true);
        await char.equipWearable(0,3,3,true);
        await char.equipWearable(0,4,4,true);
        await char.equipWearable(0,5,5,true);
        await char.equipWearable(0,6,6,true);   

        
    
    });

    it("should allow to equip helmet", async () => {
        await ite.mint(alice, 6);
        await char.createInitialCharacter('Zeus');
        await char.createArmorEntry(0);
        await char.equipHelmet(0,1,0,true);
    })
    /*

    xit("Should get the token id by owner and item id", async () => {
        const id = await ite.getTokenIdByOwnerAndItemId(alice, 1, 0);
        //const id = await ite.getTokenIdByOwnerAndItemId(alice, 1, 0);
        expect(id.words[0]).to.equal(0);
    })

    xit("should allow to equip armor", async () => {
        await char.createInitialCharacter('Zeus');
        await char.createArmorEntry(0);
        await char.equipWearable(0,1,1,true);
        await char.equipWearable(0,2,2,true);
        await char.equipWearable(0,3,3,true);
        await char.equipWearable(0,4,4,true);
        await char.equipWearable(0,5,5,true);
        await char.equipWearable(0,6,6,true);   
        id = await ite.getTokenIdByOwnerAndItemId(alice, 1, 0);
        expect(id.words[0]).to.equal(0);
    })

    it("should allow to equip helmet", async () => {
        await ite.mint(alice, 1);
        await ite.mint(alice, 2);
        await ite.mint(alice, 3);
        await ite.mint(alice, 4);
        await ite.mint(alice, 1);
        await char.createInitialCharacter('Zeus');
        await char.createArmorEntry(0);
        await char.equipHelmet(0,1,0,true);
    })
    
    xit("should allow to equip chestplate", async () => {
        await ite.mint(alice, 2);
        await char.createInitialCharacter('Zeus');
        await char.createArmorEntry(0);
        await char.equipChestplate(0,2,1,true);
    })

    
    xit("should allow to equip full set of armor", async () => {
        await char.createInitialCharacter('Zeus');
        await char.createArmorEntry(0);
        await char.equipHelmet(0,1,0,true);
        await char.equipChestplate(0,2,1,true);
        await char.equipLegging(0,3,2,true);
        await char.equipBoots(0,4,3,true);
        await char.equipNecklace(0,5,4,true);
        await char.equipRing(0,6,5,true);
    })
    
    xit("should allow to unequip armor", async () => {
        await char.createInitialCharacter('Zeus');
        await char.createArmorEntry(0);
        await char.equipHelmet(0,1,0,true);
        await char.equipLegging(0,3,2,true);
        await char.equipRing(0,6,5,true);
        await char.equipHelmet(0,1,0,false);
        await char.equipLegging(0,3,2,false);
        await char.equipRing(0,6,5,false);
    })
    
    xit("should allow to unequip armor all at once", async () => {
        await char.createInitialCharacter('Zeus');
        await char.createArmorEntry(0);
        await ite.mint(alice, 9);
        await utils.shouldThrow(char.equipHelmet(0,9,0,true));
    })
*/
    

})