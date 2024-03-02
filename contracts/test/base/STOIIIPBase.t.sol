// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;
import "forge-std/Test.sol";
import {STOIIIPHolder, STOIIIPData, IPILPolicyFrameworkManager} from "../../src/STOIIIP.sol";
import {STOIIIPHolderRegistrar} from "../../src/STOIIIPRegistrar.sol";
import {NFT} from "../../src/NFT.sol";
import {Token} from "../../src/Token.sol";
import {ERC6551Account} from "../../src/ERC6551Account.sol";
import {IP} from "@story-protocol/protocol-core/contracts/lib/IP.sol";

import "@story-protocol/protocol-core/contracts/interfaces/modules/licensing/IPILPolicyFrameworkManager.sol";

abstract contract STOIIIPHolderBase is Test, STOIIIPData {
    address public constant LICENSING_MODULE =
        address(0x950d766A1a0afDc33c3e653C861A8765cb42DbdC);
    address public constant PILPOLICY_FRAMEWORK_MANAGER =
        address(0xeAABf2b80B7e069EE449B5629590A1cc0F9bC9C2);
    address public constant REGISTRATION_MODULE =
        address(0x613128e88b568768764824f898C8135efED97fA6);
    address public constant Royalty_POLICY_LAP =
        address(0x16eF58e959522727588921A92e9084d36E5d3855);
    address public constant METADATA_PROVIDER_ADDR =
        address(0x31c65C12A6A3889cd08A055914931E2Fbe773dD6);
    address public constant IPA_REGISTRY_ADDR =
        address(0x292639452A975630802C17c9267169D93BD5a793);
    address public constant IP_RESOLVER_ADDR =
        address(0xEF808885355B3c88648D39c9DB5A0c08D99C6B71);
    address public constant STORY_PROTOCOL_GATEWAY_ADDR =
        address(0xf82EEe73c2c81D14DF9bC29DC154dD3c079d80a0);
    string public constant SEPOLIA_RPC =
        "https://ethereum-sepolia.blockpi.network/v1/rpc/public";
    uint256 sepoliaForkId;
    address owner;
    address spha;
    string[] public empty;
    STOIIIPHolderRegistrar public registrar;
    NFT public ipIssuer;
    Token public token;
    RegisterPILPolicyParams public policySettings;
    uint256 public immutable defaultTokenBalance = 1000000000000000000000000000000 ether;

    function setUp() public virtual {
        policySettings = RegisterPILPolicyParams({
            transferable: true, // Whether or not attribution is required when reproducing the work
            royaltyPolicy: address(0), // Address of a royalty policy contract that will handle royalty payments
            mintingFee: 0,
            mintingFeeToken: address(0),
            policy: PILPolicy({
                attribution: true, // Whether or not attribution is required when reproducing the work
                commercialUse: false, // Whether or not the work can be used commercially
                commercialAttribution: false, // Whether or not attribution is required when reproducing the work commercially
                commercializerChecker: address(0), // commercializers that are allowed to commercially exploit the work. If zero address, then no restrictions is enforced
                commercializerCheckerData: "0x", // Additional calldata for the commercializer checker
                commercialRevShare: 0, // Percentage of revenue that must be shared with the licensor
                derivativesAllowed: true, // Whether or not the licensee can create derivatives of his work
                derivativesAttribution: true, // Whether or not attribution is required for derivatives of the work
                derivativesApproval: false, // Whether or not the licensor must approve derivatives of the work before they can be linked to the licensor IP ID
                derivativesReciprocal: false, // Whether or not the licensee must license derivatives of the work under the same terms
                territories: empty,
                distributionChannels: empty,
                contentRestrictions: empty
            })
        });
        sepoliaForkId = vm.createFork(SEPOLIA_RPC, 5398969);
        vm.selectFork(sepoliaForkId);
        owner = _createUser("owner");
        spha = _createUser("spha");
        vm.startPrank(owner);
        registrar = new STOIIIPHolderRegistrar();
        registrar.initialize();
        ipIssuer = new NFT("IP", "MY IP");
        token = new Token();
        vm.stopPrank();
        _faucet(spha);
        _faucet(owner);
    }

    function _createUser(
        string memory name
    ) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: 1000 ether});
        vm.label(user, name);
        return user;
    }

    function _createUserWithTokenBalance(
        string memory name
    ) internal returns (address payable) {
        address payable user = _createUser(name);
        vm.startPrank(user);
        token.mint(user, defaultTokenBalance);
        assertEq(token.balanceOf(user), defaultTokenBalance);
        vm.stopPrank();
        return user;
    }

    function _faucet(address user) internal {
        vm.startPrank(user);
        token.mint(user, defaultTokenBalance);
        assertEq(token.balanceOf(user), defaultTokenBalance);
        vm.stopPrank();
    }
}
