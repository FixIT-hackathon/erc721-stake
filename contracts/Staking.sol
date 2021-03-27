//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is Ownable {
    IERC20 token;
    using SafeMath for uint256;

    mapping(address => bool) public whitelist;
    mapping(address => mapping(uint256 => Stake[])) tokenIdStakeByAsset;

    uint256 _apr;
    uint256 _minStake;
    uint256 _maxStake;
    uint256 _maxStakeDays;
    uint256 _fuel;


    uint256 _stakingAmount = 0;
    uint256 _maxStakingAmount;


    struct Stake {
        uint256 amount;
        uint256 startAt;
    }

    constructor(address erc20, uint256[] memory settings) {
        require(settings[0] > 0, "Staking: bad apr");
        require(settings[4] > 0, "Staking: bad max stake days");
        require(settings[1] < settings[2] && settings[2] < settings[3], "Staking: bad maximums");

        token = IERC20(erc20);
        _apr = settings[0];
        _minStake = settings[1];
        _maxStake = settings[2];
        _maxStakingAmount = settings[3];
        _maxStakeDays = settings[4].mul(1 days);
    }

    function refuel(uint256 amount) external onlyOwner {
        require(token.balanceOf(msg.sender) >= amount, "Staking: sender balance is too low");
        require(token.allowance(msg.sender, address(this)) >= amount, "Staking: sender allowance is too low");

        token.transferFrom(msg.sender, address(this), amount);
        _fuel = _fuel.add(amount);
    }


    function stake(uint256 amount, address erc721, uint256 tokenID) external {
        require(amount >= _minStake, "Staking: amount too small");
        require(_stakingAmount.add(amount) > _maxStakingAmount, "Staking: stake pool is full");
        require(erc721 != address(0), "Staking: erc721 contract address is null");
        require(whitelist[erc721], "Staking: erc721 contract is not whitelisted");
        require(token.balanceOf(msg.sender) >= amount, "Staking: sender balance is too low");
        require(token.allowance(msg.sender, address(this)) >= amount, "Staking: sender allowance is too low");

        token.transferFrom(msg.sender, address(this), amount);
        tokenIdStakeByAsset[erc721][tokenID].push(Stake(amount, block.timestamp));
    }

    function claimReward(address erc721, uint256 tokenID) external {
        require(IERC721(erc721).ownerOf(tokenID) == msg.sender, "Staking: sender is not owner of the token");
        uint256 reward = calculateRewardFor(erc721, tokenID);

        require(reward > 0, "Staking: zero reward");
        require(reward > _fuel, "Staking: too low fuel amount");
        _fuel.sub(reward);

        token.transfer(msg.sender, reward);

        delete tokenIdStakeByAsset[erc721][tokenID];
    }

    function stakeAmountFor(address erc721, uint256 tokenID) view public returns (uint256){
        require(tokenIdStakeByAsset[erc721][tokenID].length != 0, "Staking: staking pool is empty");

        Stake[] memory stakes = tokenIdStakeByAsset[erc721][tokenID];
        uint256 amount = 0;
        for (uint i = 0; i < stakes.length; i++) {
            amount.add(stakes[i].amount);
        }

        return amount;
    }

    function calculateRewardFor(address erc721, uint256 tokenID) view public returns (uint256){
        require(tokenIdStakeByAsset[erc721][tokenID].length != 0, "Staking: staking pool is empty");

        Stake[] memory stakes = tokenIdStakeByAsset[erc721][tokenID];
        uint256 reward = 0;
        for (uint i = 0; i < stakes.length; i++) {
            reward.add(calculateReward(stakes[i].amount, block.timestamp.sub(stakes[i].amount)));
        }

        return reward;
    }

    function listERC721(address erc721) onlyOwner public {
        require(!whitelist[erc721], "Staking: such ERC721 already existed");
        whitelist[erc721] = true;
    }

    function calculateReward(uint256 amount, uint256 timeDiff) view public returns (uint256){
        uint256 timeDiffDays = timeDiff.div(1 days);
        timeDiffDays = timeDiffDays.sub(timeDiffDays.mod(_maxStakeDays));

        return _apr.div(timeDiffDays).mul(amount).div(1 ether);
    }
}
