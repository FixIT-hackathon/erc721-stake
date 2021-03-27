//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking {
    IERC20 token;
    using SafeMath for uint256;

    mapping(address => bool) public whitelist;
    mapping(address => mapping(uint256 => Stake[])) tokenIdStakeByAsset;

    uint256 _apr;
    uint256 _minStake;
    uint256 _maxStake;

    uint256 _maxStakeDays;

    struct Stake {
        uint256 amount;
        uint256 startAt;
    }

    constructor(uint256 apr, uint256 minStake, uint256 maxStake, uint256 maxStakeDaysCount) {
        _apr = apr;
        _minStake = minStake;
        _maxStake = maxStake;
        _maxStakeDays = maxStakeDaysCount.mul(1 days);
    }


    function stake(uint256 amount, address erc721, uint256 tokenID) external {
        require(amount >= _minStake,"Staking: amount too small");
        require(erc721 != address(0), "Staking: erc721 contract address is null");
        require(whitelist[erc721], "Staking: erc721 contract is not whitelisted");
        require(token.balanceOf(msg.sender) >= amount, "Staking: sender balance is too low");
        require(token.allowance(msg.sender, address(this)) >= amount, "Staking: sender allowance is too low");

        token.transferFrom(msg.sender, address(this), amount);
        tokenIdStakeByAsset[erc721][tokenID].push(Stake(amount, block.timestamp));
    }

    function claimReward(address erc721, uint256 tokenID) external {
        require(IERC721(erc721).ownerOf(tokenID) == msg.sender, "Staking: sender is not owner of the token");
        uint256 reward = calculateRewardFor(erc721,tokenID);

        require(reward > 0, "Staking: zero reward");

        token.transfer(msg.sender, reward);
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

    function calculateReward(uint256 amount, uint256 timeDiff) view public returns (uint256){
        uint256 timeDiffDays = timeDiff.div(1 days);
        timeDiffDays = timeDiffDays.sub(timeDiffDays.mod(_maxStakeDays));

        return _apr.div(timeDiffDays).mul(amount).div(1 ether);
    }
}
