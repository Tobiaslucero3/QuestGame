// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CharacterContract is Ownable{

  uint skillIncreaseCooldownTime = 6 hours;
  
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

  struct Skill {
    uint16 skillLevel;
    uint8 increasesToNextLevel;
  }

  event NewCharacter(uint characterId, string name, uint health, uint strength, uint speed, uint intelligence);

  event CharacterLevelUp(uint characterId, uint newLevel, uint pointsToLevelUp);

  event SkillLevelUp(string skill, uint newLevel, uint increasesToNextLevelUp);

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

  function setCooldownTime(uint newTime) public onlyOwner {
    skillIncreaseCooldownTime = newTime;
  }

  function getCharacterById(uint _id) public view returns(Character memory) {
    return characters[_id];
  }

  // Where stat is what stat we want i.e. 1=health, 2=strength
  function increaseStat(uint _characterId, uint _stat) public onlyOwnerOf(_characterId) {
    require( (_stat > 0) && (_stat < 5) );
    Character storage character = characters[_characterId];
    require(_isReady(character));
    // Generate random number
    uint rand = uint(keccak256(abi.encodePacked(_characterId, msg.sender, block.timestamp)));
    rand = rand % 10; // Take only the last digit

    // 80-20 chance, either increase 1 point or 2 points.
    uint32 amountToIncrease;
    if(rand < 7)
      amountToIncrease = 1;
    else
      amountToIncrease = 2;
    
    Skill storage skill = character.health;
    string memory skillName;
    if (_stat == 1) {
      skillName = "health";
    } else if (_stat == 2) {
      skill = character.strength;
      skillName = "strength";
    } else if (_stat == 3) {
      skill = character.speed;
      skillName = "speed";
    } else if (_stat == 4) {
      skill = character.intelligence;
      skillName = "intelligence";
    }
    
    if(_increaseSkill(skill, amountToIncrease)) {
      emit SkillLevelUp(skillName, skill.skillLevel, skill.increasesToNextLevel);
    }

    character.pointsToLevelUp--;
    
    uint16 maxSize = 0; // Used to get max possible size
    maxSize--;
    // Since we can't go negative with unsigned, if the points to level up are the max possible then we should level up
    if((character.pointsToLevelUp == 0)||(character.pointsToLevelUp==maxSize)) {
      
      character.level = uint32(character.level + 1);
      character.pointsToLevelUp = uint16(character.level + (characters[_characterId].level/2));
      
      emit CharacterLevelUp(_characterId, characters[_characterId].level, characters[_characterId].pointsToLevelUp);
      
    }

  }

  function _increaseSkill(Skill storage _skill, uint _amt) internal returns(bool)  {
    // Level 1-10 it takes 2 increases to level up
    // Level 11-20 it takes 3
    // Level 21-30: it will take 5 increases to level up
    // Level 31-50: it will take 8 increases to level up 
    // Level 51-75: it will take 12 increases to level up
    // Level 76-150: it will take 15 increases
    // Level 151+: it will take 20 increases
    uint8 maxSize = 0;
    maxSize--;
    
    _skill.increasesToNextLevel = uint8(_skill.increasesToNextLevel - _amt);
    
    if((_skill.increasesToNextLevel == 0)||(_skill.increasesToNextLevel == maxSize)) {
      _skill.skillLevel = _skill.skillLevel + uint16(1);
    } else {
      return false;
    }

    uint level = _skill.skillLevel;
    if(level < 10)
      _skill.increasesToNextLevel = 2;
    else if(level < 20)
      _skill.increasesToNextLevel = 3;
    else if(level < 30)
      _skill.increasesToNextLevel = 5;
    else if(level < 50)
      _skill.increasesToNextLevel = 8;
    else if(level < 75)
      _skill.increasesToNextLevel = 12;
    else if(level < 150)
      _skill.increasesToNextLevel = 15;
    else
      _skill.increasesToNextLevel = 20;

    return true;
  }

  function _getPointsBasedOnRandPercent(uint percent) internal pure returns(uint) {
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

  function _triggerCooldown(Character storage _character) internal {
    _character.readyTimeForSkillIncrease = uint32(block.timestamp + skillIncreaseCooldownTime);
  }

  function _isReady(Character storage _character) internal view returns (bool) {
      return (_character.readyTimeForSkillIncrease <= block.timestamp);
  }

  function viewStats(uint characterId, uint stat) public view characterExists(characterId) onlyOwnerOf(characterId) returns (uint) {
    require( (stat > 0) && (stat < 5) );
    Character memory char = characters[characterId];
    if (stat == 1) {
      return char.health.skillLevel;
    } else if (stat == 2) {
      return char.strength.skillLevel;
    } else if (stat == 3) {
      return char.speed.skillLevel;
    } else if (stat == 4) {
      return char.intelligence.skillLevel;
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
