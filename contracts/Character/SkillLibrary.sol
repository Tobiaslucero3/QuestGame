// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

struct Skill {
    uint16 skillLevel;
    uint8 increasesToNextLevel;
}


library SkillLibrary {

    function getPointsBasedOnRandPercent(uint percent) public pure returns(uint) {
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


    function increaseSkill(Skill storage self, uint amt) public returns(bool)  {
        // Level 1-10 it takes 2 increases to level up
        // Level 11-20 it takes 3
        // Level 21-30: it will take 5 increases to level up
        // Level 31-50: it will take 8 increases to level up 
        // Level 51-75: it will take 12 increases to level up
        // Level 76-150: it will take 15 increases
        // Level 151+: it will take 20 increases
        
        if((self.increasesToNextLevel == 1)||((self.increasesToNextLevel == 2)&&(amt == 2))) {
            self.skillLevel = self.skillLevel + uint16(1);
        } else {
            self.increasesToNextLevel = uint8(self.increasesToNextLevel - amt);
            return false;
        }

        uint level = self.skillLevel;
        if(level < 10)
            self.increasesToNextLevel = 2;
        else if(level < 20)
            self.increasesToNextLevel = 3;
        else if(level < 30)
            self.increasesToNextLevel = 5;
        else if(level < 50)
            self.increasesToNextLevel = 8;
        else if(level < 75)
            self.increasesToNextLevel = 12;
        else if(level < 150)
            self.increasesToNextLevel = 15;
        else
            self.increasesToNextLevel = 20;

        return true;
    }
    
}