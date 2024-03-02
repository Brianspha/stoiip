import 'package:flutter/widgets.dart';
import 'package:flutter_web3/ethers.dart';
import 'dart:typed_data';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:stosp/services/data/chainsafe.dart';
import 'package:stosp/ui/viewmodels/chat/chat_viewmodel.dart';
import 'package:stosp/ui/views/chat/chat_view.dart';

import '../../../utils/constants.dart';
import '../../../utils/locator.dart';

abstract class IPViewModel extends SafeChangeNotifier {
  IPViewModelState get ipViewModelState;
  void deployIP({required IPSettings details});
  void registerIPWithPolicy(
      {required IPSematicsWithPolicy semanticsWithPolicy});

  void getOwnedIps();
  void currentIP({required IPDetails details});
  void purchaseLicense({required IPDetails details});
  void issuedLicenses();
  void setUserAddress({required String account});
  void processing();
  void initialise();
}

class IPViewModelImpl extends IPViewModel {
  IPViewModelState _ipViewModelState = IPViewModelState.empty();
  @override
  // TODO: implement ipViewModelState
  IPViewModelState get ipViewModelState => _ipViewModelState;

  @override
  void currentIP({required IPDetails details}) {
    _ipViewModelState = _ipViewModelState.copyWith(
      currentIPDetail: details,
    );
    notifyListeners();
  }

  @override
  Future<void> getOwnedIps() async {
    try {
      final ips = await _ipViewModelState.ipRegistrar
          .call('userIps', [_ipViewModelState.account]);
      debugPrint("ips: ${ips}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  Future<void> issuedLicenses() async {
    try {
      final licenses = await _ipViewModelState.ipHolder.call(
          'accountLicenses', [_ipViewModelState.currentIPDetail.ipIdAccount]);
      debugPrint("tx: ${licenses}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  Future<void> purchaseLicense({required IPDetails details}) async {
    try {
      final approvalTx = await _ipViewModelState.tokenContract.send('approve', [
        details.ipIdAccount,
        BigInt.parse(
            '115792089237316195423570985008687907853269984665640564039457584007913129639935')
      ]);
      final licenseId = await _ipViewModelState.tokenContract.send(
          'issueLicense', [
        details.policyId,
        details.ipIdAccount,
        1,
        _ipViewModelState.account,
        "0x"
      ]);
      debugPrint("approvalTx: ${approvalTx} licenseId: ${licenseId}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  Future<void> deployIP({required IPSettings details}) async {
    try {
      final tx = await _ipViewModelState.ipRegistrar.send('deployIP', [
        details.ipAssetRegistry,
        details.resolver,
        details.nftToken,
        details.registrationModule,
        details.policyRegistrar,
        details.licensingModule,
        details.spg,
        details.licenseCost,
        details.licenseToken
      ]);
      debugPrint("tx: ${tx.hash}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  void initialise() {
    final Web3Provider provider = locator.get<Web3Provider>();
    Contract ipRegistrar = Contract(
        '0xe101633d2975dF9242Be1eFA5d2fAb59cD09089B', REGISTRAR_ABI, provider);
    Contract ipHolder = Contract('0x', IP_ISSUER_ABI, provider);
    Contract tokenContract = Contract(
        '0xD4C6410283cC010f9A1c2B0d370FBAdcbe598447', TOKEN_ABI, provider);
    Contract nftIssuer = Contract(
        '0xE0A0e9d44F5662A20a4383a4f68B28E625A5c4a1', NFT_ISSUER_ABI, provider);
    _ipViewModelState = _ipViewModelState.copyWith(
        ipRegistrar: ipRegistrar,
        ipHolder: ipHolder,
        tokenContract: tokenContract,
        nftIssuer: nftIssuer);
    notifyListeners();
  }

  @override
  void setUserAddress({required String account}) {
    _ipViewModelState = _ipViewModelState.copyWith(
      account: account,
    );
    notifyListeners();
  }

  @override
  Future<void> registerIPWithPolicy(
      {required IPSematicsWithPolicy semanticsWithPolicy}) async {
    try {
      semanticsWithPolicy = semanticsWithPolicy.copyWith(
          url: locator
              .get<ChatViewModel>()
              .chatViewModelState
              .defaultJSON["jsonURI"]);
      final tx = await _ipViewModelState.ipRegistrar.send('deployIP', [
        semanticsWithPolicy.ipName,
        semanticsWithPolicy.url,
        semanticsWithPolicy.policyId,
        semanticsWithPolicy.contentHash,
        semanticsWithPolicy.tokenId,
        [
          semanticsWithPolicy.policySettings.transferable,
          semanticsWithPolicy.policySettings.royaltyPolicy,
          semanticsWithPolicy.policySettings.mintingFee,
          semanticsWithPolicy.policySettings.mintingFeeToken,
          [
            semanticsWithPolicy.policySettings.policy.attribution,
            semanticsWithPolicy.policySettings.policy.commercialUse,
            semanticsWithPolicy.policySettings.policy.commercialAttribution,
            semanticsWithPolicy.policySettings.policy.commercializerChecker,
            semanticsWithPolicy.policySettings.policy.commercializerCheckerData,
            semanticsWithPolicy.policySettings.policy.commercialRevShare,
            semanticsWithPolicy.policySettings.policy.derivativesAllowed,
            semanticsWithPolicy.policySettings.policy.derivativesAttribution,
            semanticsWithPolicy.policySettings.policy.derivativesApproval,
            semanticsWithPolicy.policySettings.policy.derivativesReciprocal,
            semanticsWithPolicy.policySettings.policy.territories,
            semanticsWithPolicy.policySettings.policy.distributionChannels,
            semanticsWithPolicy.policySettings.policy.contentRestrictions,
          ]
        ]
      ]);
      debugPrint("tx: ${tx.hash}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  void processing() {
    _ipViewModelState =
        _ipViewModelState.copyWith(processing: !_ipViewModelState.processing);
    notifyListeners();
  }
}

class IPViewModelState {
  final Contract ipRegistrar;
  final Contract ipHolder;
  final Contract tokenContract;
  final Contract nftIssuer;
  final List<IPDetails> ipDetails;
  final IPDetails currentIPDetail;
  final List<BigInt> issuedLicenses;
  final IPSettings settings;
  final String account;
  final bool processing;
  IPViewModelState(
      {required this.tokenContract,
      required this.processing,
      required this.nftIssuer,
      required this.account,
      required this.ipRegistrar,
      required this.ipHolder,
      required this.ipDetails,
      required this.settings,
      required this.currentIPDetail,
      required this.issuedLicenses});

  // copyWith method to create a new instance with the same or updated properties
  IPViewModelState copyWith(
      {Contract? ipRegistrar,
      Contract? ipHolder,
      Contract? tokenContract,
      Contract? nftIssuer,
      List<IPDetails>? ipDetails,
      IPDetails? currentIPDetail,
      IPSettings? settings,
      String? account,
      bool? processing,
      List<BigInt>? issuedLicenses}) {
    return IPViewModelState(
      processing: processing ?? this.processing,
      account: account ?? this.account,
      settings: settings ?? this.settings,
      tokenContract: tokenContract ?? this.tokenContract,
      nftIssuer: nftIssuer ?? this.nftIssuer,
      ipDetails: ipDetails ?? this.ipDetails,
      currentIPDetail: currentIPDetail ?? this.currentIPDetail,
      issuedLicenses: issuedLicenses ?? this.issuedLicenses,
      ipRegistrar: ipRegistrar ?? this.ipRegistrar,
      ipHolder: ipHolder ?? this.ipHolder,
    );
  }

  // Static method to create an empty IPViewModelState
  static IPViewModelState empty() {
    return IPViewModelState(
      ipRegistrar: Contract("", "",
          ""), // Assuming Contract has an empty constructor or similar method
      ipHolder: Contract("", "", ""),
      ipDetails: [],
      currentIPDetail: IPDetails.empty(),
      issuedLicenses: [],
      tokenContract: Contract("", "", ""),
      nftIssuer: Contract("", "", ""), settings: IPSettings.empty(),
      account: '', processing: false,
    );
  }

  @override
  int get hashCode => ipRegistrar.hashCode ^ ipHolder.hashCode;
}

class PILPolicy {
  final bool attribution;
  final bool commercialUse;
  final bool commercialAttribution;
  final String commercializerChecker;
  final Uint8List commercializerCheckerData;
  final int commercialRevShare;
  final bool derivativesAllowed;
  final bool derivativesAttribution;
  final bool derivativesApproval;
  final bool derivativesReciprocal;
  final List<String> territories;
  final List<String> distributionChannels;
  final List<String> contentRestrictions;

  PILPolicy({
    required this.attribution,
    required this.commercialUse,
    required this.commercialAttribution,
    required this.commercializerChecker,
    required this.commercializerCheckerData,
    required this.commercialRevShare,
    required this.derivativesAllowed,
    required this.derivativesAttribution,
    required this.derivativesApproval,
    required this.derivativesReciprocal,
    required this.territories,
    required this.distributionChannels,
    required this.contentRestrictions,
  });
  PILPolicy copyWith({
    bool? attribution,
    bool? commercialUse,
    bool? commercialAttribution,
    String? commercializerChecker,
    Uint8List? commercializerCheckerData,
    int? commercialRevShare,
    bool? derivativesAllowed,
    bool? derivativesAttribution,
    bool? derivativesApproval,
    bool? derivativesReciprocal,
    List<String>? territories,
    List<String>? distributionChannels,
    List<String>? contentRestrictions,
  }) {
    return PILPolicy(
      attribution: attribution ?? this.attribution,
      commercialUse: commercialUse ?? this.commercialUse,
      commercialAttribution:
          commercialAttribution ?? this.commercialAttribution,
      commercializerChecker:
          commercializerChecker ?? this.commercializerChecker,
      commercializerCheckerData:
          commercializerCheckerData ?? this.commercializerCheckerData,
      commercialRevShare: commercialRevShare ?? this.commercialRevShare,
      derivativesAllowed: derivativesAllowed ?? this.derivativesAllowed,
      derivativesAttribution:
          derivativesAttribution ?? this.derivativesAttribution,
      derivativesApproval: derivativesApproval ?? this.derivativesApproval,
      derivativesReciprocal:
          derivativesReciprocal ?? this.derivativesReciprocal,
      territories: territories ?? this.territories,
      distributionChannels: distributionChannels ?? this.distributionChannels,
      contentRestrictions: contentRestrictions ?? this.contentRestrictions,
    );
  }

  // Static method for an empty PILPolicy instance
  static PILPolicy empty() {
    return PILPolicy(
      attribution: false,
      commercialUse: false,
      commercialAttribution: false,
      commercializerChecker: '',
      commercializerCheckerData: Uint8List(0),
      commercialRevShare: 0,
      derivativesAllowed: false,
      derivativesAttribution: false,
      derivativesApproval: false,
      derivativesReciprocal: false,
      territories: [],
      distributionChannels: [],
      contentRestrictions: [],
    );
  }
}

class RegisterPILPolicyParams {
  final bool transferable;
  final String royaltyPolicy;
  final int mintingFee;
  final String mintingFeeToken;
  final PILPolicy policy;

  RegisterPILPolicyParams({
    required this.transferable,
    required this.royaltyPolicy,
    required this.mintingFee,
    required this.mintingFeeToken,
    required this.policy,
  });
  RegisterPILPolicyParams copyWith({
    bool? transferable,
    String? royaltyPolicy,
    int? mintingFee,
    String? mintingFeeToken,
    PILPolicy? policy,
  }) {
    return RegisterPILPolicyParams(
      transferable: transferable ?? this.transferable,
      royaltyPolicy: royaltyPolicy ?? this.royaltyPolicy,
      mintingFee: mintingFee ?? this.mintingFee,
      mintingFeeToken: mintingFeeToken ?? this.mintingFeeToken,
      policy: policy ?? this.policy,
    );
  }

  // Static method for an empty RegisterPILPolicyParams instance
  static RegisterPILPolicyParams empty() {
    return RegisterPILPolicyParams(
      transferable: false,
      royaltyPolicy: '',
      mintingFee: 0,
      mintingFeeToken: '',
      policy: PILPolicy.empty(),
    );
  }
}

class IPRegistration {
  final String nftName;
  final String nftDescription;
  final String nftUrl;
  final String nftImage;
  final String ipKey;
  final String ipValue;
  final IPSematics ipsemantics;

  IPRegistration({
    required this.nftName,
    required this.nftDescription,
    required this.nftUrl,
    required this.nftImage,
    required this.ipKey,
    required this.ipValue,
    required this.ipsemantics,
  });
  IPRegistration copyWith({
    String? nftName,
    String? nftDescription,
    String? nftUrl,
    String? nftImage,
    String? ipKey,
    String? ipValue,
    IPSematics? ipsemantics,
  }) {
    return IPRegistration(
      nftName: nftName ?? this.nftName,
      nftDescription: nftDescription ?? this.nftDescription,
      nftUrl: nftUrl ?? this.nftUrl,
      nftImage: nftImage ?? this.nftImage,
      ipKey: ipKey ?? this.ipKey,
      ipValue: ipValue ?? this.ipValue,
      ipsemantics: ipsemantics ?? this.ipsemantics,
    );
  }

  static IPRegistration empty() {
    return IPRegistration(
      nftName: '',
      nftDescription: '',
      nftUrl: '',
      nftImage: '',
      ipKey: '',
      ipValue: '',
      ipsemantics: IPSematics.empty(),
    );
  }
}

class IPSematicsWithPolicy {
  final String ipName;
  final String url;
  final BigInt policyId;
  final Uint8List contentHash;
  final BigInt tokenId;
  final RegisterPILPolicyParams policySettings;

  IPSematicsWithPolicy({
    required this.ipName,
    required this.url,
    required this.policyId,
    required this.contentHash,
    required this.tokenId,
    required this.policySettings,
  });
  IPSematicsWithPolicy copyWith({
    String? ipName,
    String? url,
    BigInt? policyId,
    Uint8List? contentHash,
    BigInt? tokenId,
    RegisterPILPolicyParams? policySettings,
  }) {
    return IPSematicsWithPolicy(
      ipName: ipName ?? this.ipName,
      url: url ?? this.url,
      policyId: policyId ?? this.policyId,
      contentHash: contentHash ?? this.contentHash,
      tokenId: tokenId ?? this.tokenId,
      policySettings: policySettings ?? this.policySettings,
    );
  }

  static IPSematicsWithPolicy empty() {
    return IPSematicsWithPolicy(
      ipName: '',
      url: '',
      policyId: BigInt.zero,
      contentHash: Uint8List(32),
      tokenId: BigInt.zero,
      policySettings: RegisterPILPolicyParams.empty(),
    );
  }
}

class IPSematics {
  final String ipName;
  final String url;
  final BigInt policyId;
  final Uint8List contentHash;
  final BigInt tokenId;

  IPSematics({
    required this.ipName,
    required this.url,
    required this.policyId,
    required this.contentHash,
    required this.tokenId,
  });
  IPSematics copyWith({
    String? ipName,
    String? url,
    BigInt? policyId,
    Uint8List? contentHash,
    BigInt? tokenId,
  }) {
    return IPSematics(
      ipName: ipName ?? this.ipName,
      url: url ?? this.url,
      policyId: policyId ?? this.policyId,
      contentHash: contentHash ?? this.contentHash,
      tokenId: tokenId ?? this.tokenId,
    );
  }

  static IPSematics empty() {
    return IPSematics(
      ipName: '',
      url: '',
      policyId: BigInt.zero,
      contentHash: Uint8List(32),
      tokenId: BigInt.zero,
    );
  }
}

class IPSettings {
  final String ipAssetRegistry;
  final String resolver;
  final String nftToken;
  final String registrationModule;
  final String policyRegistrar;
  final String licensingModule;
  final String spg;
  final BigInt licenseCost;
  final String licenseToken;

  IPSettings({
    required this.ipAssetRegistry,
    required this.resolver,
    required this.nftToken,
    required this.registrationModule,
    required this.policyRegistrar,
    required this.licensingModule,
    required this.spg,
    required this.licenseCost,
    required this.licenseToken,
  });
  IPSettings copyWith({
    String? ipAssetRegistry,
    String? resolver,
    String? nftToken,
    String? registrationModule,
    String? policyRegistrar,
    String? licensingModule,
    String? spg,
    BigInt? licenseCost,
    String? licenseToken,
  }) {
    return IPSettings(
      ipAssetRegistry: ipAssetRegistry ?? this.ipAssetRegistry,
      resolver: resolver ?? this.resolver,
      nftToken: nftToken ?? this.nftToken,
      registrationModule: registrationModule ?? this.registrationModule,
      policyRegistrar: policyRegistrar ?? this.policyRegistrar,
      licensingModule: licensingModule ?? this.licensingModule,
      spg: spg ?? this.spg,
      licenseCost: licenseCost ?? this.licenseCost,
      licenseToken: licenseToken ?? this.licenseToken,
    );
  }

  static IPSettings empty() {
    return IPSettings(
      ipAssetRegistry: '',
      resolver: '',
      nftToken: '',
      registrationModule: '',
      policyRegistrar: '',
      licensingModule: '',
      spg: '',
      licenseCost: BigInt.zero,
      licenseToken: '',
    );
  }
}

class IPDetails {
  final BigInt policyId;
  final BigInt indexOnIpId;
  final String ipIdAccount; // Placeholder for ERC6551Account

  IPDetails({
    required this.policyId,
    required this.indexOnIpId,
    required this.ipIdAccount, // Adjust as necessary
  });
  IPDetails copyWith({
    BigInt? policyId,
    BigInt? indexOnIpId,
    String? ipIdAccount,
  }) {
    return IPDetails(
      policyId: policyId ?? this.policyId,
      indexOnIpId: indexOnIpId ?? this.indexOnIpId,
      ipIdAccount: ipIdAccount ?? this.ipIdAccount,
    );
  }

  static IPDetails empty() {
    return IPDetails(
      policyId: BigInt.zero,
      indexOnIpId: BigInt.zero,
      ipIdAccount: '', // Adjust as necessary
    );
  }
}

class IPLease {
  final BigInt policyId;
  final String licensorIpId;
  final BigInt amount;
  final String receiver;
  final Uint8List royaltyContext;

  IPLease({
    required this.policyId,
    required this.licensorIpId,
    required this.amount,
    required this.receiver,
    required this.royaltyContext,
  });
  IPLease copyWith({
    BigInt? policyId,
    String? licensorIpId,
    BigInt? amount,
    String? receiver,
    Uint8List? royaltyContext,
  }) {
    return IPLease(
      policyId: policyId ?? this.policyId,
      licensorIpId: licensorIpId ?? this.licensorIpId,
      amount: amount ?? this.amount,
      receiver: receiver ?? this.receiver,
      royaltyContext: royaltyContext ?? this.royaltyContext,
    );
  }

  static IPLease empty() {
    return IPLease(
      policyId: BigInt.zero,
      licensorIpId: '',
      amount: BigInt.zero,
      receiver: '',
      royaltyContext: Uint8List(0),
    );
  }
}

class MetadataV1 {
  final String name;
  final Uint8List hash;
  final int registrationDate;
  final String registrant;
  final String uri;

  MetadataV1({
    required this.name,
    required this.hash,
    required this.registrationDate,
    required this.registrant,
    required this.uri,
  });
  MetadataV1 copyWith({
    String? name,
    Uint8List? hash,
    int? registrationDate,
    String? registrant,
    String? uri,
  }) {
    return MetadataV1(
      name: name ?? this.name,
      hash: hash ?? this.hash,
      registrationDate: registrationDate ?? this.registrationDate,
      registrant: registrant ?? this.registrant,
      uri: uri ?? this.uri,
    );
  }

  // A method to generate an "empty" instance of MetadataV1
  static MetadataV1 empty() {
    return MetadataV1(
      name: '',
      hash: Uint8List(32), // Assuming a placeholder for a 32-byte array
      registrationDate: 0,
      registrant: '',
      uri: '',
    );
  }
}
