//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external view returns (bool);
}

contract ERC20Faucet {
    IERC20 public token;
    address payable owner;
    uint256 public dripAmount = 100 * (10**18);
    uint256 public cooldown = 60 seconds;

    event Deposit(address indexed from, uint256 indexed amount);

    mapping(address => uint256) dripInterval;

    constructor(address tokenAddress) payable {
        owner = payable(msg.sender);
        token = IERC20(tokenAddress);
    }

    function checkBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function requestToken() public {
        require(
            token.balanceOf(address(this)) >= dripAmount,
            "Faucet has insufficient tokens for transaction"
        );
        require(msg.sender != address(0), "Invalid account");
        require(
            block.timestamp >= dripInterval[msg.sender],
            "Please wait and try again: too many requests within alloted time"
        );
        dripInterval[msg.sender] = block.timestamp + cooldown;
        token.transfer(msg.sender, dripAmount);
    }
}
