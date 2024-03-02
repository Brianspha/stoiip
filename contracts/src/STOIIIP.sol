// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IP} from "@story-protocol/protocol-core/contracts/lib/IP.sol";
import {IPAssetRegistry} from "@story-protocol/protocol-core/contracts/registries/IPAssetRegistry.sol";
import {IPResolver} from "@story-protocol/protocol-core/contracts/resolvers/IPResolver.sol";
import {RegistrationModule} from "@story-protocol/protocol-core/contracts/modules/RegistrationModule.sol";
import {ERC6551Account} from "./ERC6551Account.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {LicensingModule} from "@story-protocol/protocol-core/contracts/modules/licensing/LicensingModule.sol";
import {StoryProtocolGateway} from "@story-protocol/protocol-periphery/contracts/StoryProtocolGateway.sol";
import {IPAssetRegistry} from "@story-protocol/protocol-core/contracts/registries/IPAssetRegistry.sol";
import {IP} from "@story-protocol/protocol-core/contracts/lib/IP.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./utils/STOIIIPData.sol";

contract STOIIIPHolder is STOIIIPData {
    address public immutable NFT;
    address public immutable IP_RESOLVER;
    RegistrationModule public immutable REGISTRATION_MODULE;
    LicensingModule public immutable LICENSING_MODULE;
    IPILPolicyFrameworkManager public immutable IPIL_POLICY_MANAGER;
    StoryProtocolGateway public immutable storyProtocolGateway;
    IPAssetRegistry public immutable IPASSET_REGISTRATION_REGISTRATION;
    mapping(address user => IPDetails [] ip) public ipDetails;
    mapping(address user => mapping(uint256 tokenId => bool claimed) tokens)
        public tokensTransferred;
    mapping(address account => uint256[] licenseIds) public licensesLeased;
    uint256 public minLicenseCost;
    address public licenseToken;
    error NotOwner();
    error InvalidLeaseConfiguration();
    error InsufficientBalance();
    error InsufficientAllowance();

    constructor(IPSettings memory settings) {
        REGISTRATION_MODULE = RegistrationModule(settings.registrationModule);
        IP_RESOLVER = settings.resolver;
        NFT = settings.nftToken;
        IPIL_POLICY_MANAGER = IPILPolicyFrameworkManager(
            settings.policyRegistrar
        );
        IPASSET_REGISTRATION_REGISTRATION = IPAssetRegistry(
            settings.ipAssetRegistry
        );
        LICENSING_MODULE = LicensingModule(settings.licensingModule);
        storyProtocolGateway = StoryProtocolGateway(settings.spg);
        minLicenseCost = settings.licenseCost;
        licenseToken = settings.licenseToken;
    }

    function transfer(uint256 tokenId) public {
        if (ERC721(NFT).ownerOf(tokenId) != msg.sender) {
            revert NotOwner();
        }
        tokensTransferred[msg.sender][tokenId] = true;
        ERC721(NFT).transferFrom(msg.sender, address(this), tokenId);
        ERC721(NFT).setApprovalForAll(address(this), true);
        assert(ERC721(NFT).ownerOf(tokenId) == address(this));
    }

    function claimIP(uint256 tokenId) public {
        if (ERC721(NFT).ownerOf(tokenId) != address(this)) {
            revert NotOwner();
        }
        tokensTransferred[msg.sender][tokenId] = false;
        ERC721(NFT).transferFrom(address(this), msg.sender, tokenId);
        assert(ERC721(NFT).ownerOf(tokenId) == msg.sender);
    }

    function registerAndAddPolicy(
        IPSematicsWithPolicy memory ipSemantics
    ) external returns (address) {
        address ipId = REGISTRATION_MODULE.registerRootIp(
            ipSemantics.policyId,
            NFT,
            ipSemantics.tokenId,
            ipSemantics.ipName,
            ipSemantics.contentHash,
            ipSemantics.url
        );
        if (ERC721(NFT).ownerOf(ipSemantics.tokenId) != address(this)) {
            //@dev not ideal
            transfer(ipSemantics.tokenId);
        }
        uint256 policyId = IPIL_POLICY_MANAGER.registerPolicy(
            ipSemantics.policySettings
        );
        uint256 indexOnIpId = LICENSING_MODULE.addPolicyToIp(ipId, policyId);
        ipDetails[msg.sender].push(IPDetails({
            policyId: policyId,
            indexOnIpId: indexOnIpId,
            ipIdAccount: ERC6551Account(payable(ipId))
        }));
        claimIP(ipSemantics.tokenId);
        return ipId;
    }

    function metadata(address id) public view returns (IP.MetadataV1 memory) {
        return
            abi.decode(
                IPASSET_REGISTRATION_REGISTRATION.metadata(id),
                (IP.MetadataV1)
            );
    }

    function issueLicense(
        IPLease memory leaseDetails
    ) public returns (uint256) {
        if (leaseDetails.amount == 0) {
            revert InvalidLeaseConfiguration();
        }

        ERC20(licenseToken).transferFrom(
            msg.sender,
            leaseDetails.licensorIpId,
            minLicenseCost * leaseDetails.amount
        );

        uint256 licenseId = LICENSING_MODULE.mintLicense(
            leaseDetails.policyId,
            leaseDetails.licensorIpId,
            leaseDetails.amount,
            leaseDetails.receiver,
            leaseDetails.royaltyContext
        );
        licensesLeased[leaseDetails.licensorIpId].push(licenseId);
    }
    function accountLicenses(address account) public returns (uint256[] memory) {

        return licensesLeased[account];
    }
    function accountIPDetails(address account) public view returns (IPDetails[] memory ip ) {
        return ipDetails[account];
    }
}
