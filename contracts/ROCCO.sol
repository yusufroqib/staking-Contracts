// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Rocco is ERC20("Rocco Token", "RCO") {
    address public owner;
    address public allowedContract;

    constructor() {
        owner = msg.sender;
        _mint(msg.sender, 100000000e18);
    }

    function mint(uint256 _amount) external {
        require(msg.sender != address(0), "Address zero detected");
        require(
            msg.sender == allowedContract,
            "Contract not Allowed"
        );

        _mint(msg.sender, _amount * 1e18);
    }

    function setAllowedContract(address _contract) external {
        require(msg.sender == owner, "you are not owner");
        allowedContract = _contract;
    }
}
