const CharacterFactory = artifacts.require("CharacterFactory");
const utils = require("./helpers/utils");
const time = require("./helpers/time");

var expect = require('chai').expect;

const characterNames = ["Char 1", "Char 2"];

contract("CharacterFactory", (accounts) => {
    
    let [alice, bob] = accounts;
    let contractInstance;
    
    beforeEach(async () => {
        contractInstance = await CharacterFactory.new();
    });
    /*
    it("should be owned by the person that deploys it", async () => {
        const contractOwner = await contractInstance.owner();
        expect(contractOwner).to.equal(alice);
    })

    it("should be ownership transferrable", async () => {
        await contractInstance.transferOwnership(bob);
        const contractOwner = await contractInstance.owner();
        expect(contractOwner).to.equal(bob);
    })

    context("for character creation", async () => {
        it("should be able to create a new character", async () => {
            const result = await contractInstance.createInitialCharacter(characterNames[0], {from: alice});
            
            expect(result.receipt.status).to.equal(true);
            expect(result.logs[0].args.name).to.equal(characterNames[0]); 
        })

        it("should not allow for two characters", async () => {
            await contractInstance.createInitialCharacter(characterNames[0], {from: alice});
            await utils.shouldThrow(contractInstance.createInitialCharacter(characterNames[1], {from: alice}));
        })

        it("should give a new character all stats between 1-9", async () => {
            await contractInstance.createInitialCharacter(characterNames[0], {from: alice});

            const healthb = await contractInstance.viewStats(0, 1);
            const health = healthb.words[0];
            
            expect(health).to.be.above(0);
            expect(health).to.be.below(10);

            const strengthb = await contractInstance.viewStats(0,2);
            const strength = strengthb.words[0];

            expect(strength).to.be.above(0);
            expect(strength).to.be.below(10);

            const speedb = await contractInstance.viewStats(0,3);
            const speed = speedb.words[0];

            expect(speed).to.be.above(0);
            expect(speed).to.be.below(10);
            
            const intelligenceb = await contractInstance.viewStats(0,4);
            const intelligence = intelligenceb.words[0];

            expect(intelligence).to.be.above(0);
            expect(intelligence).to.be.below(10);
            
        })

        it("should give a new character level 1 and 2 points to next level", async () => {
            await contractInstance.createInitialCharacter(characterNames[0]);

            const levelb = await contractInstance.viewLevel(0);
            const level = levelb.words[0];
            
            expect(level).to.equal(1);

            const pointsb = await contractInstance.viewPointsToNextLevel(0);
            const points = pointsb.words[0];

            expect(points).to.equal(2);
        })
    })

    context("for character skills", async () => {
        xit("should be able to level up a skill after a cooldown", async () => {
            await contractInstance.createInitialCharacter(characterNames[0], {from: alice});
            
            var expectedStatLevel = await contractInstance.viewStats(0, 1);
            expectedStatLevel = expectedStatLevel.words[0];
            expectedStatLevel = expectedStatLevel + 1;

            await time.increase(time.duration.hours(7));
            contractInstance.increaseStat(0, 1, {from: alice});
            await time.increase(time.duration.hours(7));

            var newStatLevel = await contractInstance.viewStats(0,1);
            newStatLevel = newStatLevel.words[0];

            expect(expectedStatLevel).to.equal(newStatLevel);

        })
    })

    /*
    it("should be able to create a new character", async () => {
        const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
        //TODO: replace with expect
        assert.equal(result.receipt.status, true);
        assert.equal(result.logs[0].args.name,zombieNames[0]);
    })
    it("should not allow two zombies", async () => {
        await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
        await utils.shouldThrow(contractInstance.createRandomZombie(zombieNames[1], {from: alice}));
    })
    context("with the single-step transfer scenario", async () => {
        it("should transfer a zombie", async () => {
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
            const zombieId = result.logs[0].args.zombieId.toNumber();
            await contractInstance.transferFrom(alice, bob, zombieId, {from: alice});
            const newOwner = await contractInstance.ownerOf(zombieId);
            //TODO: replace with expect
            assert.equal(newOwner, bob);
        })
    })
    context("with the two-step transfer scenario", async () => {
        it("should approve and then transfer a zombie when the approved address calls transferFrom", async () => {
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
            const zombieId = result.logs[0].args.zombieId.toNumber();
            await contractInstance.approve(bob, zombieId, {from: alice});
            await contractInstance.transferFrom(alice, bob, zombieId, {from: bob});
            const newOwner = await contractInstance.ownerOf(zombieId);
            //TODO: replace with expect
            assert.equal(newOwner,bob);
        })
        it("should approve and then transfer a zombie when the owner calls transferFrom", async () => {
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
            const zombieId = result.logs[0].args.zombieId.toNumber();
            await contractInstance.approve(bob, zombieId, {from: alice});
            await contractInstance.transferFrom(alice, bob, zombieId, {from: alice});
            const newOwner = await contractInstance.ownerOf(zombieId);
            //TODO: replace with expect
            assert.equal(newOwner,bob);
         })
    })
    it("zombies should be able to attack another zombie", async () => {
        let result;
        result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
        const firstZombieId = result.logs[0].args.zombieId.toNumber();
        result = await contractInstance.createRandomZombie(zombieNames[1], {from: bob});
        const secondZombieId = result.logs[0].args.zombieId.toNumber();
        await time.increase(time.duration.days(1));
        await contractInstance.attack(firstZombieId, secondZombieId, {from: alice});
        //TODO: replace with expect
        assert.equal(result.receipt.status, true);
    })*/
})
