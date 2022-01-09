// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CharacterContract is Ownable{
  
  struct Character {
    string name;
    uint32 level; // This is overall character level, increases as other stats increase
    uint32 pointsToLevelUp; // This is how many points you have to increase your other stats to level up
    uint32 totalHealth;
    uint32 strength;
    uint32 speed;
    uint32 intelligence;
  }

  struct Skill {
    uint16 level;
    uint8 pointsToNextLevel;
  }

  event NewCharacter(uint characterId, string name, uint health, uint strength, uint speed, uint intelligence);

  event LevelUp(uint characterId, uint newLevel, uint pointsToLevelUp);

  Character[] public characters;

  mapping(uint => address) public characterToOwner;
  mapping(address => uint) public ownerCharacterCount;

  modifier onlyOwnerOf(uint _characterId) {
    require(msg.sender == characterToOwner[_characterId]);
    _;
  }

  modifier characterExists(uint _characterId) {
    require(_characterId < characters.length);
    _;
  }

  function getCharacterById(uint id) public view returns(Character memory) {
    return characters[id];
  }

  function _createCharacter(string memory _name, uint _health, uint _strength, uint _speed, uint _intelligence) internal {
    characters.push(Character(_name, 1, 2, uint32(_health), uint32(_strength), uint32(_speed), uint32(_intelligence) ) );
    uint id = characters.length - 1;
    characterToOwner[id] = msg.sender;
    ownerCharacterCount[msg.sender]++;
    emit NewCharacter(id, _name, _health, _strength, _speed, _intelligence);
  }

  // TODO :: make this function cost a little bit
  function createInitialCharacter(string memory _name) public {
    require(ownerCharacterCount[msg.sender] == 0);

    // We are going to take this and use sets of two digits to decide what initial stats the character gets
    uint randNum = uint(keccak256(abi.encodePacked(_name, msg.sender, block.timestamp)));
    
    uint randPercent = randNum % 100; // Get a two digit number(a percentage from 0-99)
    randNum = randNum / 100; // Get rid of those two digits

    uint health = getPointsBasedOnRandPercent(randPercent);

    randPercent = randNum % 100;
    randNum = randNum / 100;

    uint strength = getPointsBasedOnRandPercent(randPercent);

    randPercent = randNum % 100;
    randNum = randNum / 100;

    uint speed = getPointsBasedOnRandPercent(randPercent);

    randPercent = randNum % 100;
    randNum = randNum / 100;

    uint intelligence = getPointsBasedOnRandPercent(randPercent);
    
    _createCharacter(_name, health, strength, speed, intelligence);

  }

  // Where statnum is what stat we want i.e. 1=totalHealth, 2=strength
  function increaseStat(uint characterId, uint stat) public onlyOwnerOf(characterId) {
    // Generate random number
    uint rand = uint(keccak256(abi.encodePacked(characterId, msg.sender, block.timestamp)));
    rand = rand % 10; // Take only the last digit

    // 50-50 chance, either increase 1 point or 2 points.
    uint amountToIncrease;
    if(rand < 5)
      amountToIncrease = 1;
    else
      amountToIncrease = 2;
    
    if (stat == 1) {
      _increaseTotalHealth(characterId, amountToIncrease);
    } else if (stat == 2) {
      _increaseStrength(characterId, amountToIncrease);
    } else if (stat == 3) {
      _increaseSpeed(characterId, amountToIncrease);
    } else if (stat == 4) {
      _increaseIntelligence(characterId, amountToIncrease);
    }
    
    uint32 maxSize = 0; // Used to get max possible size
    maxSize--;
    // Since we can't go negative with unsigned, if the points to level up are the max possible then we should level up
    if((characters[characterId].pointsToLevelUp == 0)||(characters[characterId].pointsToLevelUp==maxSize)) {
      
      characters[characterId].level = characters[characterId].level + uint32(1);
      characters[characterId].pointsToLevelUp = characters[characterId].level + (characters[characterId].level/2);
      
      emit LevelUp(characterId, characters[characterId].level, characters[characterId].pointsToLevelUp);
    }

  }

  function _increaseTotalHealth(uint _characterId, uint _amount) internal {
    characters[_characterId].totalHealth = characters[_characterId].totalHealth + uint32(_amount);
    characters[_characterId].pointsToLevelUp = characters[_characterId].pointsToLevelUp - uint32(_amount);
  }
  
  function _increaseStrength(uint _characterId, uint _amount) internal {
    characters[_characterId].strength = characters[_characterId].strength + uint32(_amount);
    characters[_characterId].pointsToLevelUp = characters[_characterId].pointsToLevelUp - uint32(_amount);
  }
  
  function _increaseSpeed(uint _characterId, uint _amount) internal {
    characters[_characterId].speed = characters[_characterId].speed + uint32(_amount);
    characters[_characterId].pointsToLevelUp = characters[_characterId].pointsToLevelUp - uint32(_amount);
  }
  
  function _increaseIntelligence(uint _characterId, uint _amount) internal {
    characters[_characterId].intelligence = characters[_characterId].intelligence + uint32(_amount);
    characters[_characterId].pointsToLevelUp = characters[_characterId].pointsToLevelUp - uint32(_amount);
  }

  function getPointsBasedOnRandPercent(uint percent) internal pure returns(uint) {
    
    if(percent < 20) 
      return 2;
    else if(percent < 30) 
      return 3;
    else if(percent < 50) 
      return 4;
    else if(percent < 75) 
      return 5;
    else if(percent < 85) 
      return 6;
    else if(percent < 95) 
      return 7;
    else if(percent < 97) 
      return 8;
    else if(percent <= 99)
      return 9;
    return 1;
  }

  function viewStats(uint characterId, uint stat) public view characterExists(characterId) onlyOwnerOf(characterId) returns (uint) {
    require( (stat > 0) && (stat < 5) );
    Character memory char = characters[characterId];
    if (stat == 1) {
      return char.totalHealth;
    } else if (stat == 2) {
      return char.strength;
    } else if (stat == 3) {
      return char.speed;
    } else if (stat == 4) {
      return char.intelligence;
    }
    uint fakeStat = 0;
    return fakeStat;
  }

  function viewLevel(uint characterId) public view characterExists(characterId) onlyOwnerOf(characterId) returns (uint) {
    return characters[characterId].level;
  }

  function viewPointsToNextLevel(uint characterId) public view characterExists(characterId) onlyOwnerOf(characterId) returns (uint) {
    return characters[characterId].pointsToLevelUp;
  }

  constructor() {

  }
}
