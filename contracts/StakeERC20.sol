// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IROCCO {
    function mint(uint256 _amount) external;
}

contract StakeERC20 {
    address public owner;
    address public tokenAddress;
    uint256 public currentRewardPerToken;
    uint256 public lastUpdateTime;
    uint256 public totalStakedAmountBal;
    uint256 public rewardRatePerSec = 10;

    struct User {
        uint256 stakedBalance;
        uint256 rewardPerTokenPaid;
        uint256 endStakeDate;
    }

    mapping(address => User) public users;

    // Define events
    event Staked(address indexed user, uint256 amount, uint256 duration);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
    }

    function stake(uint256 _amount, uint256 _duration) external {
        require(msg.sender != address(0), "Address zero detected");
        require(_amount > 0, "Amount cannot be zero");
        require(_duration > 0, "Invalid duration");

        User storage foundUser = users[msg.sender];
        if (totalStakedAmountBal > 0) {
            currentRewardPerToken +=
                (rewardRatePerSec / totalStakedAmountBal) *
                (block.timestamp - lastUpdateTime);
        }

        // Update the reward per token paid for the user
        foundUser.rewardPerTokenPaid = currentRewardPerToken;

        uint256 _userTokenBalance = IERC20(tokenAddress).balanceOf(msg.sender);
        require(_userTokenBalance >= _amount, "Insufficient funds");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        foundUser.endStakeDate = block.timestamp + _duration;
        totalStakedAmountBal += _amount;
        foundUser.stakedBalance += _amount;
        lastUpdateTime = block.timestamp;

        // Emit the Staked event
        emit Staked(msg.sender, _amount, _duration);
    }

    function withdraw() external {
        require(msg.sender != address(0), "Address zero detected");
        require(totalStakedAmountBal > 0, "No funds in staking pool");
        require(users[msg.sender].stakedBalance > 0, "No deposit made");
        require(
            block.timestamp >= users[msg.sender].endStakeDate,
            "Withdrawal date not reached"
        );

        User storage foundUser = users[msg.sender];
        uint256 foundUserStakedBal = foundUser.stakedBalance;
        foundUser.stakedBalance = 0;

        currentRewardPerToken +=
            (rewardRatePerSec / totalStakedAmountBal) *
            (block.timestamp - lastUpdateTime);

        // Calculate reward earned by the user
        uint256 foundUserRewardEarned = foundUserStakedBal *
            (currentRewardPerToken - foundUser.rewardPerTokenPaid);

        // Update the reward per token paid for the user
        foundUser.rewardPerTokenPaid = currentRewardPerToken;

        uint256 withdrawalAmount = foundUserRewardEarned + foundUserStakedBal;

        uint256 foundUserDeposit = foundUserStakedBal;
        totalStakedAmountBal -= foundUserDeposit;
        IROCCO(tokenAddress).mint(foundUserRewardEarned);

        IERC20(tokenAddress).transfer(msg.sender, withdrawalAmount);
        lastUpdateTime = block.timestamp;

        // Emit the Withdrawn and RewardPaid events
        emit Withdrawn(msg.sender, foundUserStakedBal, foundUserRewardEarned);
        emit RewardPaid(msg.sender, foundUserRewardEarned);
    }

    function myReward() external view returns (uint256) {
        require(msg.sender != address(0), "Address zero detected");
        require(users[msg.sender].stakedBalance > 0, "No deposit made");
        User memory foundUser = users[msg.sender];

        uint256 _rewardPerTokenNow = (rewardRatePerSec / totalStakedAmountBal) *
            (block.timestamp - lastUpdateTime);

        uint256 accumCurrentRewardPerToken = currentRewardPerToken +
            _rewardPerTokenNow;

        // Calculate reward earned by the user
        uint256 foundUserRewardEarned = foundUser.stakedBalance *
            (accumCurrentRewardPerToken - foundUser.rewardPerTokenPaid);

        return foundUserRewardEarned;
    }
}
