import 'package:example/features/terminal/pax_terminal_service/pax_terminal_service.dart';
import 'package:example/features/terminal/presentation/terminal_setting/terminal_setting_page.dart';

class PaxTerminalButton extends GetView<FlutterPaxAcceptance> {
  const PaxTerminalButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(const TerminalSettingPage());
      },
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.credit_card,
              size: 32,
            ),
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: Obx(
              () {
                final terminalStatus = controller.state;

                Widget statusWidget = const CircularProgressIndicator();
                switch (terminalStatus) {
                  case FlutterPaxAcceptance.loading:
                    statusWidget = const SizedBox.square(
                        dimension: 18, child: CircularProgressIndicator());
                    break;
                  case FlutterPaxAcceptance.connected:
                    statusWidget = const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 18,
                    );
                    break;
                  case FlutterPaxAcceptance.disconnected:
                    statusWidget = const Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.amber,
                      size: 18,
                    );
                    break;
                  case FlutterPaxAcceptance.notPaired:
                    statusWidget = const Icon(
                      Icons.do_not_disturb,
                      color: Colors.red,
                      size: 18,
                    );
                    break;
                  case FlutterPaxAcceptance.processing:
                    statusWidget = const Icon(
                      Icons.currency_exchange_outlined,
                      color: Colors.blue,
                      size: 18,
                    );
                    break;
                }

                return statusWidget;
              },
            ),
          )
        ],
      ),
    );
  }
}
