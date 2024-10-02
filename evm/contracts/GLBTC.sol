// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GLBTC is ERC20, Ownable {
    // Constructor to initialize the token name, symbol, and decimals
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_
    ) ERC20(name, symbol) {
        _decimals = decimals_;
    }

    // Variable to store the decimals
    uint8 private _decimals;

    // Override the decimals function to return the custom decimals value
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    // Function for the owner to mint new tokens
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Function for the owner to burn tokens
    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}