// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {STOIIIPData} from "./utils/STOIIIPData.sol";
import {STOIIIPHolder} from "./STOIIIP.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract STOIIIPHolderRegistrar is STOIIIPData, Initializable {
    mapping(address user => address[] ips) public userIPCollection;

    function initialize() public initializer {}

    function deployIP(
        IPSettings memory settings
    ) public returns (STOIIIPHolder) {
        STOIIIPHolder instance = new STOIIIPHolder(settings);
        userIPCollection[msg.sender].push(address(instance));
        return instance;
    }

    function userIps(address user) public view returns (address[] memory) {
        return userIPCollection[user];
    }
}
