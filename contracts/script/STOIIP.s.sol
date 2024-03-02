import {STOIIIPHolder, STOIIIPData, IPILPolicyFrameworkManager} from "../src/STOIIIP.sol";
import {STOIIIPHolderRegistrar} from "../src/STOIIIPRegistrar.sol";
import {NFT} from "../src/NFT.sol";
import {Token} from "../src/Token.sol";
import {ERC6551Account} from "../src/ERC6551Account.sol";
import {IP} from "@story-protocol/protocol-core/contracts/lib/IP.sol";
import "@story-protocol/protocol-core/contracts/interfaces/modules/licensing/IPILPolicyFrameworkManager.sol";

import "forge-std/Script.sol";

contract STOIIPScript is Script, STOIIIPData {
    uint256 public immutable defaultTokenBalance =
        1000000000000000000000000000000 ether;

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
    RegisterPILPolicyParams public policySettings;
    STOIIIPHolderRegistrar public registrar;
    NFT public ipIssuer;
    Token public token;
    string[] public empty;
    address owner = address(0x73109Baf60baB74B9E8273DfD4236d17C56CFc67);
    address spha = address(0x8c458F7C2B3B9fbccbe2cEB60566F2B8e5384C95);

    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("LOCAL_HOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
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
        registrar = new STOIIIPHolderRegistrar();
        registrar.initialize();
        ipIssuer = new NFT("IP", "MY IP");
        token = new Token();
        _faucet(spha);
        _faucet(owner);
        _createIP();
        console.log("ipIssuer: %o", address(ipIssuer));
        console.log("tokenAddress: %o", address(token));
        console.log("registrar: %o", address(registrar));
        vm.stopBroadcast();
    }

    function run() public {
        vm.broadcast();
    }

    function _createIP() public {
        //Register IP
        STOIIIPHolder instance = registrar.deployIP(
            IPSettings({
                ipAssetRegistry: IPA_REGISTRY_ADDR,
                resolver: IP_RESOLVER_ADDR,
                nftToken: address(ipIssuer),
                registrationModule: REGISTRATION_MODULE,
                policyRegistrar: PILPOLICY_FRAMEWORK_MANAGER,
                licensingModule: LICENSING_MODULE,
                spg: STORY_PROTOCOL_GATEWAY_ADDR,
                licenseCost: 10000e18, //@dev 10K of whatever token,
                licenseToken: address(token)
            })
        );
        //Mint NFT
        ipIssuer.mint(owner);
        assert(ipIssuer.ownerOf(1) == owner);
        //approve stosp contract
        ipIssuer.setApprovalForAll(address(instance), true);
        assert(ipIssuer.isApprovedForAll(owner, address(instance)) == true);
        //transfer ip to contract
        // register IP
        instance.registerAndAddPolicy(
            IPSematicsWithPolicy({
                url: "google.com",
                ipName: "Special IP",
                policyId: 1,
                tokenId: 1,
                contentHash: bytes32(
                    abi.encodePacked(
                        '{"description": "Test SPG contract", ',
                        '"external_link": "https://storyprotocol.xyz", ',
                        '"image": "https://storyprotocol.xyz/ip.jpeg", ',
                        '"name": "SPG Default Collection"}'
                    )
                ),
                policySettings: policySettings
            })
        );
        IPDetails[] memory accountDetails = instance.accountIPDetails(owner);
        IPDetails memory details = accountDetails[0];
        IP.MetadataV1 memory metada = instance.metadata(
            address(details.ipIdAccount)
        );

        console.log("IP Details");
        console.log(address(details.ipIdAccount));
        console.log(details.indexOnIpId);
        console.log(details.policyId);
        console.log(metada.name);
        console.log("sphasBalance:%o", token.balanceOf(spha));
        token.approve(address(instance), UINT256_MAX);
        instance.issueLicense(
            IPLease({
                receiver: spha,
                policyId: details.policyId,
                licensorIpId: address(details.ipIdAccount),
                amount: 1,
                royaltyContext: "0x"
            })
        );
        uint256[] memory licenseIds = instance.accountLicenses(
            address(details.ipIdAccount)
        );
        console.log("licenseIds: %o", licenseIds[0]);
        console.log(
            "ipIdAccount:%o",
            token.balanceOf(address(details.ipIdAccount))
        );
        console.log("instanceAddress: %o", address(instance));
    }

    function _faucet(address user) internal {
        token.mint(user, defaultTokenBalance);
        assert(token.balanceOf(user) == defaultTokenBalance);
    }
}
