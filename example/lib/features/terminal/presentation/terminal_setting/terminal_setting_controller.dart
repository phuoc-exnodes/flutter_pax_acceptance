import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ws_client/features/terminal/presentation/terminal_setting/dialog/reset_setting_dialog.dart';

import '../../pax_terminal_service/pax_terminal_service.dart';

class TerminalSettingController extends GetxController {
  final pageState = TerminalSettingStatus.loading.obs;

  final PaxTerminalService _service = Get.find<PaxTerminalService>();
  final oldHost = ''.obs;
  final newHost = ''.obs;

  TextEditingController paxIPController =
      TextEditingController(text: '192.168.31.181:8443');

  TextEditingController paxCodeController = TextEditingController();
  FocusNode paxCodeFieldNode = FocusNode();
  FocusNode paxIPFieldNode = FocusNode();

  final Map<ConnectTerminalError, String?> errors = {
    ConnectTerminalError.code: null,
    ConnectTerminalError.ip: null,
  };

  @override
  void onReady() {
    _service.listenForStatus(checkServiceState);
    oldHost.value = _service.host ?? '';
    newHost.value = oldHost.value;
    paxIPController.text = oldHost.value;

    super.onReady();
  }

  @override
  void dispose() {
    paxIPController.dispose();
    paxCodeController.dispose();
    paxCodeFieldNode.dispose();
    paxIPFieldNode.dispose();
    _service.unSubcribeStatus();
    super.dispose();
  }

  Future<void> checkServiceState(int status) async {
    switch (status) {
      case PaxTerminalService.loading:
        pageState.value = TerminalSettingStatus.loading;
        break;
      case PaxTerminalService.notReady:
        pageState.value = TerminalSettingStatus.notReady;
        break;
      case PaxTerminalService.notPaired:
        pageState.value = TerminalSettingStatus.notPaired;
        break;
      case PaxTerminalService.disconnected:
        pageState.value = TerminalSettingStatus.disconnected;
        break;
      case PaxTerminalService.connected:
        pageState.value = TerminalSettingStatus.connected;
        break;
      case PaxTerminalService.processing:
        pageState.value = TerminalSettingStatus.processing;
        break;
      default:
    }
  }

  Future<void> onPairTap() async {
    if (pageState.value == TerminalSettingStatus.loading) return;
    if (!validateIPAndPort(paxIPController.text)) return;

    pageState.value = TerminalSettingStatus.loading;

    final success = await _service.pair(
        host: paxIPController.text,
        posId: '123123',
        setupCode: paxCodeController.text);
    if (success && _service.state == PaxTerminalService.disconnected) {
      oldHost.value = _service.host!;
      newHost.value = oldHost.value;
      paxIPController.text = oldHost.value;
      Get.back();
    }
  }

  Future<void> onDisconnectTap() async {
    pageState.value = TerminalSettingStatus.loading;
    await _service.disconnect();
  }

  void onConnectTap() async {
    pageState.value = TerminalSettingStatus.loading;
    final success = await _service.connect();
    if (!success) {
      Get.showSnackbar(const GetSnackBar(
        title: 'Connect Terminal failed',
        message: 'Check IP Address or pair terminal again',
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> onResetTap() async {
    final accept = await _showConfirmDialog();
    if (accept == true) {
      _service.resetSetting();
    }
  }

  Future<bool?> _showConfirmDialog() async {
    return Get.dialog<bool?>(const ResetSettingDialog());
  }

  bool validateIPAndPort(String combinedString) {
    final ipRegex = RegExp(
        r'^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]?):(\d+)$');
    final match = ipRegex.matchAsPrefix(combinedString);

    if (match == null) {
      return false;
    }

    final portString = match[1];

    if (portString == null) {
      return false;
    }
    final port = int.tryParse(portString);
    if (port == null || port < 0 || port > 65535) {
      return false;
    }

    return true;
  }

  void onCancelConnectTap() {
    _service.cancelConnect();
  }

  void onCancelPairTap() {}

  onSaveHostTap() async {
    final inputHost = paxIPController.text;
    if (!validateIPAndPort(inputHost)) {
      errors[ConnectTerminalError.ip] = 'Invalid IP';
      return;
    }
    errors[ConnectTerminalError.ip] = null;

    final success = await _service.updateHost(inputHost);
    if (success) {
      oldHost.value = inputHost;
      newHost.value = inputHost;
    }
  }

  void onHostInputChange(String value) {
    newHost.value = value;
    if (!validateIPAndPort(value)) {
      errors[ConnectTerminalError.ip] = 'Invalid IP';
      return;
    }
  }
}

enum TerminalSettingStatus {
  notPaired,
  disconnected,
  connected,
  loading,
  processing,
  notReady,
}

enum ConnectTerminalError {
  ip,
  code,
}
