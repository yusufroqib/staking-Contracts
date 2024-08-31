// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract StakeETH is ReentrancyGuard {
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 reward;
    }

    mapping(address => Stake) public stakes;
    uint256 public constant MINIMUM_STAKE = 0.1 ether;
    uint256 public constant STAKING_PERIOD = 30 days;
    uint256 public constant REWARD_RATE = 10; // 10% APY

    event Staked(address indexed user, uint256 amount, uint256 startTime, uint256 endTime);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);

    function stake() external payable nonReentrant {
        require(msg.value >= MINIMUM_STAKE, "Stake amount too low");
        require(stakes[msg.sender].amount == 0, "Already staking");

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + STAKING_PERIOD;

        stakes[msg.sender] = Stake({
            amount: msg.value,
            startTime: startTime,
            endTime: endTime,
            reward: 0
        });

        emit Staked(msg.sender, msg.value, startTime, endTime);
    }

    function withdraw() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No active stake");
        require(block.timestamp >= userStake.endTime, "Staking period not ended");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = userStake.amount + reward;

        userStake.amount = 0;
        userStake.reward = 0;

        (bool success, ) = payable(msg.sender).call{value: totalAmount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, userStake.amount, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        Stake storage userStake = stakes[user];
        if (userStake.amount == 0) return 0;

        uint256 stakingDuration = Math.min(block.timestamp - userStake.startTime, STAKING_PERIOD);

        return (userStake.amount * REWARD_RATE * stakingDuration) / (365 days) / 100;
    }

    function getStakeInfo() external view returns (uint256, uint256, uint256, uint256) {
        Stake storage userStake = stakes[msg.sender];
        return (userStake.amount, userStake.startTime, userStake.endTime, calculateReward(msg.sender));
    }

     receive() external payable {}
}