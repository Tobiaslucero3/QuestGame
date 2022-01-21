// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ArmorLibrary.sol";

interface ItemInterface {
    function getBalanceOfOwnerSpecificItemId(address addr, uint itemId) external view returns (uint);

    function getTokenIdByOwnerAndItemId(address owner, uint itemId, uint instance) external view returns (uint);

    function getItemIdByTokenId(uint tokenId) external view returns (uint);

    function getMinLevelByTokenId(uint itemId) external view returns (uint);

    function transfer(address from, address to, uint256 tokenId) external;
    
    function isWearable(uint itemId) external view returns (bool);
    function isHeadItem(uint itemId) external view returns (bool);
    function isBodyItem(uint itemId) external view returns (bool);
    function isLegItem(uint itemId) external view returns (bool);
    function isFeetItem(uint itemId) external view returns (bool);
    function isNeckItem(uint itemId) external view returns (bool);
    function isRingItem(uint itemId) external view returns (bool);

    function isOneHandedWieldable(uint itemId) external view returns (bool);
    function isTwoHandedWieldable(uint itemId) external view returns (bool);

    function setEquipped(uint tokenId, bool equipped) external;
    function isEquipped(uint tokenId) external view returns (bool);
}

interface CharacterInterface {
    function ownerOf(uint256 tokenId) external view returns (address);
    function isAboveLevel(uint _characterId, uint _level) external view returns (bool);
}

contract Armor is Ownable {

    using ArmorLibrary for CharacterArmor;

    event WearableEquipped(uint attributeNum, uint itemId, uint tokenId);

    mapping(uint => CharacterArmor) private characterToArmor;

    address public itemContractAddress;

    address public characterContractAddress;

    function setItemContractAddress(address addr) public onlyOwner {        
        itemContractAddress = addr;
    }
    
    function setCharacterContractAddress(address addr) public onlyOwner {        
        characterContractAddress = addr;
    }

    modifier armorEntryExists(uint _characterId) {
        require(characterToArmor[_characterId].enabled, "armor entry is not enabled for this character");
        _;
    }
    
    modifier characterContractOrOwner(uint _characterId) {
        require(((CharacterInterface(characterContractAddress).ownerOf(_characterId)==msg.sender)
        || (msg.sender == characterContractAddress)), "caller is not owner of the character or the character contract");
        _;
    }
    
    modifier approvedContractOrOwner(uint _characterId) {
        require(((CharacterInterface(characterContractAddress).ownerOf(_characterId)==msg.sender)
        || (msg.sender == characterContractAddress) || (msg.sender == itemContractAddress) ), 
        "caller is not owner of the character or the character contract");
        _;
    }

    modifier characterAboveLevel(uint _characterId, uint _level) {
        require(CharacterInterface(characterContractAddress).isAboveLevel(_characterId, _level), "Character is not above level required");
        _;
    }

    // TODO make this function cost money
    function createArmorEntry(uint _characterId) public approvedContractOrOwner(_characterId) {
        require(((!characterToArmor[_characterId].enabled)&&(characterToArmor[_characterId].headId==0)),
        "There's already an entry for this character"); 
        characterToArmor[_characterId].enabled = true;
    }

    function getArmor(uint _characterId) public view characterContractOrOwner(_characterId) returns (CharacterArmor memory) {
        return characterToArmor[_characterId];
    }

    function getArmorIdByCharacterIdAndAttributeNum(uint _characterId, uint attributeNum) external view
    armorEntryExists(_characterId) approvedContractOrOwner(_characterId) returns (uint) {
        return ArmorLibrary.getAttribute(characterToArmor[_characterId], attributeNum);
    }

    function equipInItemContract(address sndr, uint itemId, uint tokenId, bool equip) internal {
        uint itemCount = ItemInterface(itemContractAddress).getBalanceOfOwnerSpecificItemId(sndr, itemId);
        require((itemCount>=1), "user does not own one of the items");

        bool alreadyEquipped = ItemInterface(itemContractAddress).isEquipped(tokenId);

        if(equip) {
            require(!alreadyEquipped, "item is already equipped and you are trying to equip it");
        } else {
            require(alreadyEquipped, "item is not equipped and you are trying to unequip it");
        }
        
        ItemInterface(itemContractAddress).setEquipped(tokenId, equip);
    }

    function equipWearable(uint _characterId, uint attributeNum, uint tokenId, address sndr, bool equip) public 
    armorEntryExists(_characterId) characterContractOrOwner(_characterId)
    characterAboveLevel(_characterId, ItemInterface(itemContractAddress).getMinLevelByTokenId(tokenId)) {
        uint itemId = ItemInterface(itemContractAddress).getItemIdByTokenId(tokenId);

        bool alreadyEquipped = ArmorLibrary.getAttribute(characterToArmor[_characterId], attributeNum)!=0;

        if(equip) {
            require(!alreadyEquipped, "Item is already equipped and you are trying to equip it");
        } else {
            require(alreadyEquipped, "Item is not equipped and you are trying to unequip it");
            require(ArmorLibrary.getAttribute(characterToArmor[_characterId], attributeNum)==itemId, "trying to unequip not the item");
        }

        if(attributeNum == ArmorLibrary.headIdNum) 
            require(ItemInterface(itemContractAddress).isHeadItem(itemId), "item is not a head item");
        else if(attributeNum == ArmorLibrary.armorIdNum)
            require(ItemInterface(itemContractAddress).isBodyItem(itemId), "item is not a body item");
        else if(attributeNum == ArmorLibrary.leggingIdNum)
            require(ItemInterface(itemContractAddress).isLegItem(itemId), "item is not a leg item");
        else if(attributeNum == ArmorLibrary.bootsIdNum)
            require(ItemInterface(itemContractAddress).isFeetItem(itemId), "item is not a feet item");
        else if(attributeNum == ArmorLibrary.necklaceIdNum)
            require(ItemInterface(itemContractAddress).isNeckItem(itemId), "item is not a necklace item");
        else if(attributeNum == ArmorLibrary.ringIdNum)
            require(ItemInterface(itemContractAddress).isRingItem(itemId), "item is not a ring item");

        equipInItemContract(sndr, itemId, tokenId, equip);
        if(equip)
            ArmorLibrary.setAttribute(characterToArmor[_characterId], attributeNum, tokenId);
        else
            ArmorLibrary.setAttribute(characterToArmor[_characterId], attributeNum, 0);
    }
    
    function equipOneHand(uint _characterId, uint tokenId, address sndr, bool equip, bool left) 
    public armorEntryExists(_characterId) characterContractOrOwner(_characterId) 
    characterAboveLevel(_characterId, ItemInterface(itemContractAddress).getMinLevelByTokenId(tokenId)) {

        bool alreadyEquipped;
        if(left)
            alreadyEquipped = (characterToArmor[_characterId].leftHandId!=0);
        else
            alreadyEquipped = (characterToArmor[_characterId].rightHandId!=0);

        if(equip) {
            require(!alreadyEquipped, "Hand is already equipped and you are trying to equip it");
        } else {
            require(alreadyEquipped, "Hand is not equipped and you are trying to unequip it");
            if(left)
                require(characterToArmor[_characterId].leftHandId==tokenId, "trying to unequip not the Hand");
            else
                require(characterToArmor[_characterId].rightHandId==tokenId, "trying to unequip not the Hand");
        }

        uint itemId = ItemInterface(itemContractAddress).getItemIdByTokenId(tokenId);
    
        require(ItemInterface(itemContractAddress).isOneHandedWieldable(itemId), "item is not a one hand item");

        equipInItemContract(sndr, itemId, tokenId, equip);

        if(left)
            if(equip)
                characterToArmor[_characterId].leftHandId = uint64(tokenId);
            else
                characterToArmor[_characterId].leftHandId = 0;
        else
            if(equip)
                characterToArmor[_characterId].rightHandId = uint64(tokenId);
            else
                characterToArmor[_characterId].rightHandId = 0;
    }

    function equipTwoHand(uint _characterId, uint tokenId, address sndr, bool equip) 
    public armorEntryExists(_characterId) characterContractOrOwner(_characterId) 
    characterAboveLevel(_characterId, ItemInterface(itemContractAddress).getMinLevelByTokenId(tokenId)) {

        if(equip) {
            require(((characterToArmor[_characterId].leftHandId==0)&&(characterToArmor[_characterId].rightHandId==0)),
            "Hands Are already equipped and you are trying to equip it");
        } else {
            require(((characterToArmor[_characterId].leftHandId!=0)&&(characterToArmor[_characterId].rightHandId!=0)),
            "Both hands are not equipped and you are trying to unequip two handed");
            
            require(((characterToArmor[_characterId].leftHandId==tokenId)&&(characterToArmor[_characterId].rightHandId==tokenId)), 
            "trying to unequip a different item id to the one that is already equipped");
        }

        uint itemId = ItemInterface(itemContractAddress).getItemIdByTokenId(tokenId);
    
        require(ItemInterface(itemContractAddress).isTwoHandedWieldable(itemId), "item is not a two hand item");

        equipInItemContract(sndr, itemId, tokenId, equip);

        if(equip) {
            characterToArmor[_characterId].leftHandId = uint64(tokenId);
            characterToArmor[_characterId].rightHandId = uint64(tokenId);
        } else {
            characterToArmor[_characterId].leftHandId = 0;
            characterToArmor[_characterId].rightHandId = 0;
        }
    }

    function unequipFullArmorSet(uint _characterId, address sndr) external armorEntryExists(_characterId) 
    characterContractOrOwner(_characterId) {
        uint tokenId;
        uint leftHand;
        for(uint i = ArmorLibrary.getMinAttributeNum(); i <= ArmorLibrary.getMaxAttributeNum(); i++) {
            tokenId = ArmorLibrary.getAttribute(characterToArmor[_characterId], i);
            if(tokenId!=0) {
                if(i==7)
                    leftHand = tokenId;
                if(i==8)
                    if(tokenId==leftHand)
                        break;
                equipWearable(_characterId, i, tokenId, sndr, false);
            }
        }
    }

    function getAllEquipped(uint characterId) external armorEntryExists(characterId) 
    approvedContractOrOwner(characterId) view returns (uint[] memory){
        return characterToArmor[characterId].getAllEquipped();
    }
}