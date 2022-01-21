// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../Armor/ArmorInterface.sol";

contract ItemFramework is ERC721, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint => uint) private tokenIdToItemId;
    mapping(uint => bool) private tokenIdEquipped;

    Item[] public items;

    struct Item {
        string itemName;
        uint64 itemId;
        uint64 totalSupply; // if 0 then unlimited
        bool allMinted;
        
        bytes1 itemData;
        uint8 minLevel;
    }

    address characterContract;
    address armorContract;

    function setCharacterContractAddress(address addr) public onlyOwner {
        characterContract = addr;
    }

    function setArmorContractAddress(address addr) public onlyOwner {
        armorContract = addr;
    }

    modifier notAllMinted(uint itemId) {
        uint amount = getAmountOfCurrentlyMintedItemsByItemId(itemId);
        uint index = getIndexOnItemArrayByItemId(itemId);
        require((items[index].totalSupply > amount)&&(!items[index].allMinted), "there are no tokens left to mint");
        _;
    }

    modifier itemExists(uint itemId) {
        require(itemId!=0, "item id is zero"); 
        require(_itemIdExists(itemId), "item does not exist");
        _;
    }

    function isEquipped(uint tokenId) public view returns (bool) {
        require(_exists(tokenId));

        return tokenIdEquipped[tokenId];
    }

    function _isItemType(bytes1 _itemData, bytes1 _itemType) internal pure returns (bool) {
        return((_itemType & _itemData) == _itemType);
    }

    function setEquipped(uint tokenId, bool equipped) external{
        require(_exists(tokenId));
        require(msg.sender == armorContract, "not the armor contract");

        tokenIdEquipped[tokenId] = equipped;
    }

    function getLength() public view returns (uint) {
        return items.length;    
    }

    function getMinLevelByTokenId(uint tokenId) public view returns (uint) {
        require(_exists(tokenId), "the token does not exist");
        uint itemId = getItemIdByTokenId(tokenId);
        uint index = getIndexOnItemArrayByItemId(itemId);
        return items[index].minLevel;
    }

    function _itemIdExists(uint _itemId) private view returns (bool){
        for(uint i = 0; i < items.length; i++) {
            if(items[i].itemId==_itemId) {
                return true;
            }
        }
        return false;
    }

    function getTokenIdByOwnerAndItemId(address sender, uint itemId, uint instance) public view itemExists(itemId) returns (uint) {
        require( getBalanceOfOwnerSpecificItemId(sender, itemId) > instance, "owner has less tokens than instance requested");
        
        for(uint i = 1; i < _tokenIds.current(); i++ ) {
            if((tokenIdToItemId[i]==itemId)&&(ownerOf(i)==sender)) {
                if(instance == 0) {
                    return i;
                }
                else if(instance > 0){
                    instance--;
                }
            }
        }
        return 0;

    }

    function getIndexOnItemArrayByItemId(uint itemId) public view itemExists(itemId) returns (uint) {
        for(uint i = 0; i <  items.length; i++) {
            if(items[i].itemId==itemId) {
                return i;
            }
        }
        return 0;
    }

    function getItemById(uint itemId) public view itemExists(itemId) returns (Item memory) {
        return items[getIndexOnItemArrayByItemId(itemId)];
    }

    function getCurrentId() public view returns (uint) {
        return _tokenIds.current();
    }

    function getAmountOfCurrentlyMintedItemsByItemId(uint itemId) public view returns (uint) {
        uint counter = 0;
        for(uint i = 1; i < _tokenIds.current(); i++) {  
            if(tokenIdToItemId[i] == itemId) {
                counter++;
            }         
        }
        return counter;
    }

    function getItemIdByTokenId(uint tokenId) public view returns (uint) {
        require(_exists(tokenId), "token id has not been minted yet");
        return tokenIdToItemId[tokenId];
    }

    function addItemToAllItems(string memory name, uint itemId, uint totalSupply, uint minLevel, bytes1 itemData) public onlyOwner {
        require(!_itemIdExists(itemId), "item already exists");
        items.push(Item(name, uint64(itemId), uint64(totalSupply), false, itemData, uint8(minLevel)));
    }

    function getBalanceByOwner(address addr) public view returns (uint) {
        return uint(balanceOf(addr));
    }

    function getBalanceOfOwnerSpecificItemId(address addr, uint itemId) public view returns (uint) {
        uint counter = 0;
        for(uint i = 1; i < _tokenIds.current(); i++) {
            if(ownerOf(i)==addr) {
                if(getItemIdByTokenId(i)==itemId) {
                    counter++;
                }
            }
        }
        return counter;

    }

    function mint(address recipient, uint itemId) public itemExists(itemId) notAllMinted(itemId) {

        //require(getBalanceOfOwnerSpecificItemId(recipient, itemId)==0); // Make sure the owner only mints one
        //TODO: Require that this contract is being called by the owner of all the contracts , i.e. call it through the backend

        uint tokenId = _tokenIds.current();

        _safeMint(recipient, tokenId);

        tokenIdToItemId[tokenId] = itemId;

        uint index = getIndexOnItemArrayByItemId(itemId);

        uint amount = getAmountOfCurrentlyMintedItemsByItemId(itemId);
        if(items[index].totalSupply == amount) {
            items[index].allMinted = true;
        }

        _tokenIds.increment();
    }

    function transferFromCharacterContract(address from, address to, uint256 tokenId) external {
        require(msg.sender == characterContract);
        _safeTransfer(from, to, tokenId, "");
    }

    function setApprovalForCharacterContract(uint characterId) public{
        uint[] memory armor = ArmorInterface(armorContract).getAllEquipped(characterId);
        for(uint i = 0; i < armor.length; i++) { 
            approve(characterContract, armor[i]);
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(!isEquipped(tokenId), "item is equipped, cannot transfer until unequipped");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function getOwnersTokenIds(address addr) public view returns (uint[] memory) {
        uint[] memory result = new uint[](balanceOf(addr));
        uint counter = 0;
        for(uint i = 1; i < _tokenIds.current(); i++) {
            if(ownerOf(i)==addr) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }

    function getOwnersItemsIds(address addr, bool sorted) public view returns (uint[] memory) {
        uint[] memory tokenIds = getOwnersTokenIds(addr);
        uint[] memory itemIds = new uint[](tokenIds.length);
        uint uniqueItemIdCounter = 0;
        uint itemId;
        bool unique = true;
        for(uint i = 0; i < tokenIds.length; i++) {
            itemId = getItemIdByTokenId(tokenIds[i]);
            for(uint j = 0; j < itemIds.length; j++) {
                if(itemId==itemIds[j]) {
                    unique = false;
                }
            }
            if(unique) {
                itemIds[uniqueItemIdCounter] = itemId;
                uniqueItemIdCounter++;
            }
            unique = true;
        }

        uint[] memory result = new uint[](uniqueItemIdCounter);
        for(uint i = 0; i < uniqueItemIdCounter; i++) {
            result[i] = itemIds[i];
        }

        if(sorted) {
            for(uint i = 0; i < uniqueItemIdCounter; i++) {
                for(uint j = i+1; j < uniqueItemIdCounter; j++) {
                    if(result[i] > result[j]) { 
                        itemId = result[i];
                        result[i] = result[j];
                        result[j] = itemId;
                    }
                }
            }
        }

        return result;
    }

    constructor() ERC721("Item", "ITM") {
        //bytes1 itemData = 0x03; // Head item
        addItemToAllItems("Thor's Helmet", 1, 1000, 0, 0x00); // Head
        addItemToAllItems("Thor's Helmet", 9, 1000,10,  0x00); // Head
        addItemToAllItems("Achilles' Chestplate", 2, 500,0,  0x04);
        addItemToAllItems("Poseidon's Trousers", 3, 100, 0, 0x08);
        addItemToAllItems("Aquaman's Boots", 4, 100, 0, 0x0c);
        addItemToAllItems("God's Necklace", 5, 100,0,  0x10);
        addItemToAllItems("Zeus' Ring", 6, 100, 0, 0x14);

        addItemToAllItems("Odin's Staff", 7, 100, 0, 0x07);
        addItemToAllItems("Perseus's Sword", 8, 100, 0, 0x03);

        _tokenIds.increment(); // So we start at token ID = 1 LOLOLOLOLOLOLOLOLOLOL

    }

}