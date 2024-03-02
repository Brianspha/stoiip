// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;
import "@story-protocol/protocol-core/contracts/interfaces/modules/licensing/IPILPolicyFrameworkManager.sol";
import {ERC6551Account} from "../ERC6551Account.sol";

abstract contract STOIIIPData {
    struct IPRegistration {
        string nftName;
        string nftDescription;
        string nftUrl;
        string nftImage;
        string ipKey;
        string ipValue;
        IPSematics ipsemantics;
    }

    struct IPSematicsWithPolicy {
        string ipName;
        string url;
        uint256 policyId; //@dev should always be zero it works this way
        bytes32 contentHash;
        uint256 tokenId;
        RegisterPILPolicyParams policySettings;
    }
    struct IPSematics {
        string ipName;
        string url;
        uint256 policyId; //@dev should always be zero it works this way
        bytes32 contentHash;
        uint256 tokenId;
    }
    struct IPSettings {
        address ipAssetRegistry;
        address resolver;
        address nftToken;
        address registrationModule;
        address policyRegistrar;
        address licensingModule;
        address spg;
        uint256 licenseCost;
        address licenseToken;
    }
    struct IPDetails {
        uint256 policyId;
        uint256 indexOnIpId;
        ERC6551Account ipIdAccount;
    }
    struct IPLease {
        uint256 policyId;
        address licensorIpId;
        uint256 amount;
        address receiver;
        bytes royaltyContext;
    }
}
