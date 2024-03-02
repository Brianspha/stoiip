// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./base/STOIIIPBase.t.sol";

contract STOIIIPHolderRegistrarTest is STOIIIPHolderBase {
    function setUp() public override {
        STOIIIPHolderBase.setUp();
    }

    function test_createIP() public {
        vm.selectFork(sepoliaForkId);
        vm.startPrank(owner);

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
        assertEq(ipIssuer.ownerOf(1), owner);
        //approve stosp contract
        ipIssuer.setApprovalForAll(address(instance), true);
        assertEq(ipIssuer.isApprovedForAll(owner, address(instance)), true);
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
        vm.stopPrank();
        console.log("sphasBalance:%o", token.balanceOf(spha));
        vm.startPrank(spha);
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

        vm.stopPrank();
    }
}
