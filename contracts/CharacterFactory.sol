// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./CharacterContract.sol";

contract CharacterFactory is CharacterContract {

    function _createCharacter(string memory _name, uint _health, uint _strength, uint _speed, uint _intelligence) internal {
        characters.push(Character(_name, 1, 2, Skill(uint16(_health), uint8(2)), Skill(uint16(_strength), uint8(2)), 
            Skill(uint16(_speed), uint8(2)), Skill(uint16(_intelligence), uint8(2)), uint32(block.timestamp) ) );
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

        uint health = _getPointsBasedOnRandPercent(randPercent);

        randPercent = randNum % 100;
        randNum = randNum / 100;

        uint strength = _getPointsBasedOnRandPercent(randPercent);

        randPercent = randNum % 100;
        randNum = randNum / 100;

        uint speed = _getPointsBasedOnRandPercent(randPercent);

        randPercent = randNum % 100;
        randNum = randNum / 100;

        uint intelligence = _getPointsBasedOnRandPercent(randPercent);
        
        _createCharacter(_name, health, strength, speed, intelligence);
    }
}