const Staking = artifacts.require("Staking");
const Token = artifacts.require("TestToken");
const Contract = artifacts.require("TestERC721");
const truffleAssert = require('truffle-assertions');

contract("staking", function (accounts) {
    let staking
    let token
    let contract

    let amounts = [5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000]
    let uris = ["", "", "", "", "", "", "", "", "", ""]
    let settings = [110, 1, 500, 1000, 365]

    beforeEach("deploying", async () => {
        token = await Token.new(accounts, amounts)
        contract = await Contract.new(accounts, uris)

        staking = await Staking.new(token.address, settings)
    })

    it("should deploy token", async () => {
        let addr = token.address

        assert.notEqual(addr, 0x0)
        assert.notEqual(addr, 0)
        assert.notEqual(addr, undefined)
    });

    it("should deploy contract", async () => {
        let addr = contract.address

        assert.notEqual(addr, 0x0)
        assert.notEqual(addr, 0)
        assert.notEqual(addr, undefined)
    });

    it("should deploy staking", async () => {
        let addr = staking.address

        assert.notEqual(addr, 0x0)
        assert.notEqual(addr, 0)
        assert.notEqual(addr, undefined)
    });

    it("should stake", async () => {
        await staking.listERC721(contract.address)
        await token.approve(staking.address, 1002, {
            from: accounts[1]
        })

        let result = await staking.stake(1001, contract.address, 1, {
            from: accounts[1]
        })
    })


    it("should failed with amount to small", async () => {
        await staking.listERC721(contract.address)
        await token.approve(staking.address, 1002, {
            from: accounts[1]
        })

        let result = staking.stake(0, contract.address, 1, {
            from: accounts[1]
        })

        truffleAssert.reverts(result, "Staking: amount too small");
    })

    it("should failed with sender allowance is too low", async () => {
        await staking.listERC721(contract.address)
        let result = staking.stake(1001, contract.address, 1, {
            from: accounts[1]
        })

        truffleAssert.reverts(result, "Staking: sender allowance is too low");
    })

    it("should add to whitelist", async () => {
        await staking.listERC721(contract.address)


        assert.equal(await staking.whitelist(contract.address), true)
    })

    it("should failed with erc721 contract is not whitelisted", async () => {
        let result = staking.stake(1001, contract.address, 1, {
            from: accounts[1]
        })


        truffleAssert.reverts(result, "Staking: erc721 contract is not whitelisted");
    })


    it("should failed with stake pool is full", async () => {
        await staking.listERC721(contract.address)
        await token.approve(staking.address, 1002, {
            from: accounts[1]
        })

        let result = staking.stake(1001, contract.address, 1, {
            from: accounts[1]
        })

        truffleAssert.reverts(result, "Staking: stake pool is full");
    })


})