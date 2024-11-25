library flutter_pax_acceptance;

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalTerminalDS {
  static const String privateCertificate = '/private_certificate.pem';
  static const String rootCAPath = '/root_ca.pem';
  static const String terminalUrl = '/terminal_url.txt';

  Future<bool> saveRootCA(String cert) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + rootCAPath);
      await file.writeAsString(cert);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> savePrivateCert(String cert) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + privateCertificate);
      await file.writeAsString(cert);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> loadRootCA() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + rootCAPath);
      return file.readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  Future<String?> loadPrivateCert() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(directory.path + privateCertificate);
      return file.readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveHost(String host) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + terminalUrl);

      await file.writeAsBytes(utf8.encode(host));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> loadHost() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + terminalUrl);
      if (!file.existsSync()) return null;
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteCertificate() async {
    try {
      final directoryPath = (await getApplicationDocumentsDirectory()).path;
      final privateCertificateFile = File(directoryPath + privateCertificate);
      await privateCertificateFile.delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteHost() async {
    try {
      final directoryPath = (await getApplicationDocumentsDirectory()).path;
      final file = File(directoryPath + terminalUrl);
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      final directoryPath = (await getApplicationDocumentsDirectory()).path;

      final file = File(directoryPath + terminalUrl);
      final rootCAPathFile = File(directoryPath + rootCAPath);
      final privateCertificateFile = File(directoryPath + privateCertificate);

      await file.delete();
      await rootCAPathFile.delete();
      await privateCertificateFile.delete();

      return true;
    } catch (e) {
      return false;
    }
  }
}
