// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./CharacterFactory.sol";

contract CharacterSkill is CharacterFactory{

    uint skillIncreaseCooldownTime = 6 hours;

    function setCooldownTime(uint newTime) public onlyOwner {
        skillIncreaseCooldownTime = newTime;
    }

    event SkillLevelUp(string skillName, uint skillLevel, uint increasesToNextLevel);

    event CharacterLevelUp(uint characterId, uint newLevel, uint pointsToLevelUp);

    // Where stat is what stat we want i.e. 1=health, 2=strength
    function increaseStat(uint characterId, uint stat) public returns (bool) {
        Character storage character = characters[characterId];
        require( (stat > 0) && (stat < 5) );
        require(_isReadyForSkillIncrease(characterId));
        // Generate random number
        uint rand = uint(keccak256(abi.encodePacked(characterId, msg.sender, block.timestamp)));
        rand = rand % 10; // Take only the last digit

        // 80-20 chance, either increase 1 point or 2 points.
        uint32 amountToIncrease;
        if(rand < 7)
            amountToIncrease = 1;
        else
            amountToIncrease = 2;

        Skill storage skill = character.health;
        string memory skillName;
        if (stat == 1) {
            skillName = "health";
        } else if (stat == 2) {
            skill = character.strength;
            skillName = "strength";
        } else if (stat == 3) {
            skill = character.speed;
            skillName = "speed";
        } else if (stat == 4) {
            skill = character.intelligence;
            skillName = "intelligence";
        }

        if(SkillLibrary.increaseSkill(skill, amountToIncrease)) {
            emit SkillLevelUp(skillName, skill.skillLevel, skill.increasesToNextLevel);
        }

        character.pointsToLevelUp--;

        
        if(character.pointsToLevelUp == 0) {
            
            character.level = uint32(character.level + 1);
            character.pointsToLevelUp = uint16(character.level + (character.level/2));
            return true;
            
        }
        return false;

    }

    function _isReadyForSkillIncrease(uint _characterId) internal view returns (bool) {
        return (characters[_characterId].readyTimeForSkillIncrease <= block.timestamp);
    }
/*
    function _increaseSkill(Skill storage _skill, uint _amt) internal returns(bool)  {
        // Level 1-10 it takes 2 increases to level up
        // Level 11-20 it takes 3
        // Level 21-30: it will take 5 increases to level up
        // Level 31-50: it will take 8 increases to level up 
        // Level 51-75: it will take 12 increases to level up
        // Level 76-150: it will take 15 increases
        // Level 151+: it will take 20 increases
        
        if((_skill.increasesToNextLevel == 1)||((_skill.increasesToNextLevel == 2)&&(_amt == 2))) {
            _skill.skillLevel = _skill.skillLevel + uint16(1);
        } else {
            _skill.increasesToNextLevel = uint8(_skill.increasesToNextLevel - _amt);
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
    }*/

    function _triggerCooldown(uint _characterId) internal {
        characters[_characterId].readyTimeForSkillIncrease = uint32(block.timestamp + skillIncreaseCooldownTime);
    }
   
}
