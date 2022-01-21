// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../Armor/ArmorInterface.sol";
import "./CharacterSkill.sol";
    
interface GameItemInterface {
    
    function transferFromCharacterContract(address from, address to, uint256 tokenId) external;
}

contract CharacterEquip is CharacterSkill {

    modifier noArmorEquipped(uint _characterId) {
        uint[] memory armor = ArmorInterface(armorContractAddress).getAllEquipped(_characterId);
        for(uint i = 0; i < armor.length; i++) { 
            require((armor[i]==0), 
            "Trying to just transfer character however character has armor equipped either unequip your armor or transfer with transferCharacterWithArmor");
        }
        _;
    }

    uint minLevelToEquipArmor = 0;

    function setMinLevelToEquipArmor(uint _level) public onlyOwner {
        minLevelToEquipArmor = _level;
    }

    address armorContractAddress;

    function setArmorContractAddress(address addr) public onlyOwner {
        armorContractAddress = addr;
    }

    address itemContractAddress;

    function setItemContractAddress(address addr) public onlyOwner {
        itemContractAddress = addr;
    }

    function transferCharacterWithArmor(address from, address to, uint256 characterId) public {
        require(_isApprovedOrOwner(_msgSender(), characterId), "ERC721: transfer caller is not owner nor approved");
        uint[] memory armor = ArmorInterface(armorContractAddress).getAllEquipped(characterId);
        for(uint i = 0; i < armor.length; i++) { 
            GameItemInterface(itemContractAddress).transferFromCharacterContract(from, to, armor[i]);
        }
        _safeTransfer(from, to, characterId, "");
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override noArmorEquipped(tokenId) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function createArmorEntry(uint _characterId) public onlyOwnerOf(_characterId) aboveLevel(_characterId, minLevelToEquipArmor)  {
        ArmorInterface(armorContractAddress).createArmorEntry(_characterId);
    }
    
    function unequipFullArmorSet(uint _characterId) public onlyOwnerOf(_characterId) {
        ArmorInterface(armorContractAddress).unequipFullArmorSet(_characterId, msg.sender);
    }

    function equipWearable(uint _characterId, uint attributeNum, uint tokenId, bool equip) public onlyOwnerOf(_characterId) {
        ArmorInterface(armorContractAddress).equipWearable(_characterId, attributeNum, tokenId, msg.sender, equip);
    }    
    
    function equipOneHand(uint _characterId, uint tokenId, bool equip, bool left) public onlyOwnerOf(_characterId) {
        ArmorInterface(armorContractAddress).equipOneHand(_characterId, tokenId, msg.sender, equip, left);
    }    
    
    function equipTwoHand(uint _characterId, uint tokenId, bool equip) public onlyOwnerOf(_characterId) {
        ArmorInterface(armorContractAddress).equipTwoHand(_characterId, tokenId, msg.sender, equip);
    }    

}
    
