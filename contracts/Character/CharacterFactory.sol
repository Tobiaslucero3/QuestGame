// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SkillLibrary.sol";


contract CharacterFactory is Ownable, ERC721 {

    struct Character {
      string name;

      uint32 level; // This is overall character level, increases as other stats increase
      uint16 pointsToLevelUp; // This is how many points you have to increase your other stats to level up
      
      Skill health;
      Skill strength;
      Skill speed;
      Skill intelligence;

      uint32 readyTimeForSkillIncrease;
    }

    event NewCharacter(uint characterId, string name, uint health, uint strength, uint speed, uint intelligence);

    Character[] internal characters;

    modifier characterExists(uint _characterId) {
      require(_characterId < characters.length, "Character does not exist");
      _;
    }

    modifier aboveLevel(uint _characterId, uint _level) {
      require(isAboveLevel(_characterId, _level), "character does not meet the level requirements");
      _;
    }

    modifier onlyOwnerOf(uint _characterId) {
      require(msg.sender == ownerOf(_characterId), "Sender is not the owner of the character");
      _;
    }

    function isAboveLevel(uint characterId, uint level) public view returns (bool) {
      return(characters[characterId].level > level);
    }

    function getCharacterById(uint characterId) public view characterExists(characterId) onlyOwnerOf(characterId) returns(Character memory) {
      return characters[characterId];
    }

    // TODO :: make this function cost a little bit
    function createInitialCharacter(string memory _name) public {
      require(balanceOf(msg.sender) == 0, "User already owns a character");

      // We are going to take this and use sets of two digits to decide what initial stats the character gets
      uint randNum = uint(keccak256(abi.encodePacked(_name, msg.sender, block.timestamp)));
      
      uint randPercent = randNum % 100; // Get a two digit number(a percentage from 0-99)
      randNum = randNum / 100; // Get rid of those two digits

      uint health = SkillLibrary.getPointsBasedOnRandPercent(randPercent);

      randPercent = randNum % 100;
      randNum = randNum / 100;

      uint strength = SkillLibrary.getPointsBasedOnRandPercent(randPercent);

      randPercent = randNum % 100;
      randNum = randNum / 100;

      uint speed = SkillLibrary.getPointsBasedOnRandPercent(randPercent);

      randPercent = randNum % 100;
      randNum = randNum / 100;

      uint intelligence = SkillLibrary.getPointsBasedOnRandPercent(randPercent);
      
      _createCharacter(_name, health, strength, speed, intelligence);
    }

    function _createCharacter(string memory _name, uint _health, uint _strength, uint _speed, uint _intelligence) internal {
      Character memory character;

      character.name = _name;
      character.level = 1;
      character.pointsToLevelUp = 2;

      character.health = Skill(uint16(_health), uint8(2));
      character.strength = Skill(uint16(_strength), uint8(2));
      character.speed = Skill(uint16(_speed), uint8(2));
      character.intelligence = Skill(uint16(_intelligence), uint8(2));
      character.readyTimeForSkillIncrease = uint32(block.timestamp);
      
      characters.push(character);
      uint id = characters.length - 1;
      _safeMint(msg.sender , id); // Mint the new character
      emit NewCharacter(id, _name, _health, _strength, _speed, _intelligence);
    }

    constructor() ERC721("Character Token", "CHRCTR") { }
}
