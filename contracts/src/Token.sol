// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("TOKEN", "TK") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
