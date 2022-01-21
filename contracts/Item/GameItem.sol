// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ItemFramework.sol";

contract WieldableItem {
    bytes1 constant wieldable = 0x03; // xx00 we get the corresponding bit and make sure it is 0
    bytes1 constant wieldableChecker = 0x03; // xx11

    function checkWieldable(bytes1 itemData) internal pure returns (bool) {
        return((itemData & wieldableChecker)==wieldable);
    }

    bytes1 constant oneHand = 0x03;
    bytes1 constant twoHand = 0x07;

    bytes1 private constant itemTypeChecker = 0x07;

    function isWieldableItemType(bytes1 itemData, bytes1 itemType) internal pure returns (bool) {
        return((itemData & itemTypeChecker)==itemType);
    }
}

contract WearableItem {
    bytes1 constant wearable = 0x00; // xx00
    bytes1 constant wearableChecker = 0x03; // xx11

    function checkWearable(bytes1 itemData) internal pure returns (bool) {
        return((itemData & wearableChecker)==wearable);
    }

    bytes1 private constant itemTypeChecker = 0x1f;
    function isWearableItemType(bytes1 itemData, bytes1 itemType) internal pure returns (bool) {
        return ((itemData & itemTypeChecker)==itemType);
    }

    bytes1 constant headItem = 0x00; // xxx0 0000
    bytes1 constant bodyItem = 0x04; // xxx0 0100
    bytes1 constant legItem = 0x08; //  xxx0 1000
    bytes1 constant feetItem = 0x0c; // xxx0 1100    
    bytes1 constant neckItem = 0x10; // xxx1 0000    
    bytes1 constant ringItem = 0x14; // xxx1 0100  

}

contract GameItem is ItemFramework, WearableItem, WieldableItem {
/*
    modifier onlyOfType(uint itemId, bytes1 itemType) {
        require(isOfType(itemId, itemType));
        _;
    }

    modifier onlyWearable(uint itemId) {
        require(isWearable(itemId));
        _;
    }

    modifier onlyWieldable(uint itemId) {
        require(isWieldable(itemId));
        _;
    }*/

    function isWearable(uint itemId) external view returns (bool) {
        return checkWearable(items[getIndexOnItemArrayByItemId(itemId)].itemData);
    }

    function isWieldable(uint itemId) external view returns (bool) {
        return checkWieldable(items[getIndexOnItemArrayByItemId(itemId)].itemData);
    }

    function isHeadItem(uint itemId) external view returns (bool) { 
        return isWearableItemType(items[getIndexOnItemArrayByItemId(itemId)].itemData, headItem);
    }

    function isBodyItem(uint itemId) external view returns (bool){
        return isWearableItemType(items[getIndexOnItemArrayByItemId(itemId)].itemData, bodyItem);
    }

    function isLegItem(uint itemId) external view returns (bool){
        return isWearableItemType(items[getIndexOnItemArrayByItemId(itemId)].itemData, legItem);
    }

    function isFeetItem(uint itemId) external view returns (bool){
        return isWearableItemType(items[getIndexOnItemArrayByItemId(itemId)].itemData, feetItem);
    }

    function isNeckItem(uint itemId) external view returns (bool){
        return isWearableItemType(items[getIndexOnItemArrayByItemId(itemId)].itemData, neckItem);
    }
    
    function isRingItem(uint itemId) external view returns (bool){
        return isWearableItemType(items[getIndexOnItemArrayByItemId(itemId)].itemData, ringItem);
    }

    function isOneHandedWieldable(uint itemId) external view returns (bool) {
        return isWieldableItemType(items[getIndexOnItemArrayByItemId(itemId)].itemData, oneHand);
    }
    
    function isTwoHandedWieldable(uint itemId) external view returns (bool){
        return isWieldableItemType(items[getIndexOnItemArrayByItemId(itemId)].itemData, twoHand);
    }

}