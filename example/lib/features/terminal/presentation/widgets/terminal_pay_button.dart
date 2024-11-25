import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:simple_ws_client/features/terminal/pax_terminal_service/pax_terminal_service.dart';

///A button to represent available state of PAX terminal to process a sale request
class TerminalPayButton extends GetView<PaxTerminalService> {
  const TerminalPayButton(this.onTap, {super.key});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.state;
      switch (controller.state) {
        case PaxTerminalService.connected:
          return _buttonEnabled();
        case PaxTerminalService.processing:
          return _buttonDisabled(processing: true);
        default:
          return _buttonDisabled();
      }
    });
  }

  Widget _buttonEnabled() {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Pay With Card',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buttonDisabled({bool processing = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pay With Terminal',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (processing) ...[
            const SizedBox(
              width: 10,
            ),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ]
        ],
      ),
    );
  }
}
