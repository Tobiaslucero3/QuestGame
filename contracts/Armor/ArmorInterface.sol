// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
    
interface ArmorInterface {
    function createArmorEntry(uint _characterId) external;
    function equipWearable(uint _characterId, uint attributeNum, uint tokenId, address sndr, bool equip) external;

    function equipOneHand(uint _characterId, uint tokenId, address sndr, bool equip, bool left) external;
    function equipTwoHand(uint _characterId, uint tokenId, address sndr, bool equip) external;

    function unequipFullArmorSet(uint _characterId, address sndr) external;

    function getArmorIdByCharacterIdAndAttributeNum(uint _characterId, uint attributeNum) external view returns (uint);

    function getMinAttributeNum() external pure returns (uint);
    function getMaxAttributeNum() external pure returns (uint);

    function getAllEquipped(uint characterId) external returns (uint[] memory);
}