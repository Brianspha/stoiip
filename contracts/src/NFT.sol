// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint256 public totalSupply;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mint(address to) external returns (uint256 id) {
        id = ++totalSupply;
        _mint(to, id);
    }
}