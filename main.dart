import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:znn_swap_utility/znn_swap_utility.dart';

Future main(List<String> args) async {
  if (args.length != 2) {
    print('Missing arguments');
    exit(1);
  }

  final LEGACY_PILLAR_ADDRESS = args[0];
  final ALPHANET_PILLAR_ADDRESS = args[1];

  print('Insert legacy wallet password:');
  stdin.echoMode = false;
  final LEGACY_WALLET_PW = stdin.readLineSync() ?? '';
  stdin.echoMode = true;

  final legacyWalletFilePath = Directory.current.path + '/wallet.dat';

  final swapFilePath =
      await _getSwpFilePath(legacyWalletFilePath, LEGACY_WALLET_PW);

  final swapFileEntries = await readSwapFile(swapFilePath);

  for (final entry in swapFileEntries) {
    if (entry.address == LEGACY_PILLAR_ADDRESS) {
      if (!_isLegacyPillar(entry.keyIdHashHex)) {
        print('Address ' +
            LEGACY_PILLAR_ADDRESS +
            ' is not a Legacy Pillar address or it has been used to spawn a Pillar already.');
      }
      final signature =
          entry.signLegacyPillar(LEGACY_WALLET_PW, ALPHANET_PILLAR_ADDRESS);
      _writeOutput(LEGACY_PILLAR_ADDRESS, entry.pubKeyB64, signature,
          entry.keyIdHashHex, ALPHANET_PILLAR_ADDRESS);
      break;
    }
  }
  print('Finished');
}

Future<String> _getSwpFilePath(String walletDatPath, String walletPass) async {
  String swapWalletDirectoryPath = Directory.current.path;
  String swapWalletFilePathWithExtension =
      Directory.current.path + '/wallet.swp';

  if (!(await File(swapWalletFilePathWithExtension).exists())) {
    String response = await exportSwapFile(swapWalletDirectoryPath, walletPass);
    if (response.isNotEmpty) {
      throw response;
    }
    print('.swp file succesfully generated.');
  } else {
    print('.swp already exists. No need to regenerate.');
  }
  return swapWalletFilePathWithExtension;
}

bool _isLegacyPillar(String keyIdHashHex) {
  final pillars = _getLegacyPillars();
  for (final p in pillars) {
    if (p['keyIdHash'] == keyIdHashHex) {
      return true;
    }
  }
  return false;
}

List<dynamic> _getLegacyPillars() {
  final json =
      File(Directory.current.path + '/legacy_pillars.json').readAsStringSync();
  final map = jsonDecode(json);
  return map['list'];
}

_writeOutput(String legacyAddress, String pubKey, String signature,
    String keyIdHashHex, String alphanetAddress) {
  File('output.txt').writeAsStringSync('Legacy Pillar Address: ' +
      legacyAddress +
      '\nPublic Key: ' +
      pubKey +
      '\nSignature: ' +
      signature +
      '\nKey ID Hash HEX: ' +
      keyIdHashHex +
      '\nAlphanet Pillar Address: ' +
      alphanetAddress);
  print('Signature succesfully written to output.txt for legacy address ' +
      legacyAddress);
}
