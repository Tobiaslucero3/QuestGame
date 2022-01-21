// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

struct CharacterArmor {
    bool enabled;
    uint64 headId; // tokenId
    uint64 armorId;
    uint64 leggingId;
    uint64 bootsId;

    uint64 necklaceId;
    uint64 ringId;

    uint64 leftHandId;
    uint64 rightHandId;
}

library ArmorLibrary {
    uint constant public headIdNum = 1;
    uint constant public armorIdNum = 2;
    uint constant public leggingIdNum = 3;
    uint constant public bootsIdNum = 4;
    uint constant public necklaceIdNum = 5;
    uint constant public ringIdNum = 6;
    uint constant public leftHandIdNum = 7;
    uint constant public rightHandIdNum = 8;

    //1=headId,2=armorId,3=leggingId,4=bootsId,5=ringId,6=necklaceId,7=leftHandId,8=rightHandID
    function getAttribute(CharacterArmor memory self, uint attributeNum) internal pure returns (uint) {
        require(((attributeNum >= headIdNum)&&(attributeNum <= rightHandIdNum)), "Attribute num given was not equippable");
        if(attributeNum == headIdNum) 
            return self.headId;
        else if(attributeNum == armorIdNum)
            return self.armorId;
        else if(attributeNum == leggingIdNum)
            return self.leggingId;
        else if(attributeNum == bootsIdNum)
            return self.bootsId;
        else if(attributeNum == necklaceIdNum)
            return self.necklaceId;
        else if(attributeNum == ringIdNum)
            return self.ringId;
        else if(attributeNum == leftHandIdNum)
            return self.leftHandId;
        else if(attributeNum == rightHandIdNum)
            return self.rightHandId;
        return 0;
    }

    function setAttribute(CharacterArmor storage self, uint attributeNum, uint value) internal {
        require(((attributeNum >= headIdNum)&&(attributeNum <= rightHandIdNum)), "Attribute num given was not equippable");
        if(attributeNum == headIdNum) 
            self.headId = uint64(value);
        else if(attributeNum == armorIdNum)
            self.armorId = uint64(value);
        else if(attributeNum == leggingIdNum)
            self.leggingId = uint64(value);
        else if(attributeNum == bootsIdNum)
            self.bootsId = uint64(value);
        else if(attributeNum == necklaceIdNum)
            self.necklaceId = uint64(value);
        else if(attributeNum == ringIdNum)
            self.ringId = uint64(value);
        else if(attributeNum == leftHandIdNum)
            self.leftHandId = uint64(value);
        else if(attributeNum == rightHandIdNum)
            self.rightHandId = uint64(value);
    }

    function getAllEquipped(CharacterArmor memory self) internal pure returns (uint[] memory) {
        uint minAttribNum = headIdNum;
        uint maxAttribNum = rightHandIdNum;

        uint[8] memory armorArray;
        uint counter = 0;
        uint leftHand;
        for(uint i = minAttribNum; i <= maxAttribNum; i++) { 
            uint tokenId = getAttribute(self,i);
            if(tokenId!=0) {
                if(i==7)
                    leftHand = tokenId;
                if(i==8)
                    if(tokenId==leftHand)
                        break;
                armorArray[counter] = tokenId;
                counter++;
            }
        }
        
        uint[] memory result = new uint[](counter);

        for(uint i = 0; i < counter; i++) {
            result[i] = armorArray[i];
        }

        return result;
    }

    function getMinAttributeNum() internal pure returns (uint) {
        return headIdNum;
    }
    
    function getMaxAttributeNum() internal pure returns (uint) {
        return headIdNum;
    }
}