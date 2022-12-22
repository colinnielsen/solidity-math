// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract StakingRewards {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    address public owner;
    uint256 public rewardDuration;
    uint256 public rewardEndTime; // time when the reward period is over
    uint256 public lastUpdatedTimestamp; // time when the reward rate was last updated
    uint256 public tokensRewardedPerSecond; // the amount of tokens the user gets per second
    uint256 public rewardPerToken; // the amount of rewards the get paid out per token staked
    mapping(address => uint256) public userPerTokenPaidOut;
    mapping(address => uint256) public userRewardsEarned;

    uint256 totalStaked;
    mapping(address => uint256) public userStaked;

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardsToken);
    }

    ///// owner functions //////

    function setRewardsDuration(uint256 _durationTime) public onlyOwner {
        require(rewardEndTime < block.timestamp, "reward period not finished");
        rewardDuration = _durationTime;
    }

    /// @notice send reward tokens to this contract and set the reward rate
    function topUpRewardTokens(uint256 _newRewardsIn) public onlyOwner {
        uint256 newTokenRewardRate;
        // if the reward period has expired
        if (block.timestamp > rewardEndTime) {
            // allow the admin to simply set the reward rate
            newTokenRewardRate = _newRewardsIn / rewardDuration;
        } else {
            // if the reward period is still ongoing
            // find the amount of reward token to still be issued out
            uint256 remainingRewards = tokensRewardedPerSecond *
                (rewardEndTime - block.timestamp);
            // calculate the new token rewarded per second,
            newTokenRewardRate =
                (remainingRewards + _newRewardsIn) /
                rewardDuration;
        }

        require(newTokenRewardRate > 0, "rewardRate is 0");
        tokensRewardedPerSecond = newTokenRewardRate;
        rewardEndTime = block.timestamp + rewardDuration; // why??
        lastUpdatedTimestamp = block.timestamp;

        // pull the token amount into the contract
        rewardToken.transferFrom(
            msg.sender,
            address(this),
            tokensRewardedPerSecond * rewardDuration
        );
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "amout == 0");
        unchecked {
            userStaked[msg.sender] += _amount;
            totalStaked += _amount;
        }

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        // update vars
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "amount == 0");
        userStaked[msg.sender] -= _amount;
        totalStaked -= _amount;

        stakingToken.transfer(msg.sender, _amount);
    }

    function amountEarned(address _account) public view returns (uint256) {}

    function getReward() public {}

    modifier onlyOwner() {
        require(msg.sender == owner, "ACCESS");
        _;
    }
}
