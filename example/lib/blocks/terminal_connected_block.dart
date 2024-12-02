import 'package:flutter/material.dart';
import 'package:flutter_pax_acceptance/flutter_pax_acceptance.dart';

class TerminalConnectedBlock extends StatefulWidget {
  const TerminalConnectedBlock(this.paxAcceptance, {super.key});
  final FlutterPaxAcceptance paxAcceptance;
  @override
  State<TerminalConnectedBlock> createState() => _TerminalConnectedBlockState();
}

class _TerminalConnectedBlockState extends State<TerminalConnectedBlock> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async {
                  final saleRequest = SalePaymentRequest(
                    merchantReferenceCode: 'awda',
                    amountDetails:
                        AmountDetails.sale(currency: 'USD', amount: '1.00'),
                  );
                  PayzliPaymentPAX(widget.paxAcceptance).transactionSale(
                    saleRequest,
                    onDoneApproved: (response) {
                      debugPrint('onDoneApproved:');
                      debugPrint(response.toJson().toString());
                    },
                    onDoneAborted: (response) {
                      debugPrint('onDoneAborted:');
                      debugPrint(response.toJson().toString());
                    },
                    onError: (error) {
                      debugPrint('onError:');
                      debugPrint(error);
                    },
                    onStatus: (response) {
                      debugPrint('onStatus:');
                      debugPrint(response.toJson().toString());
                    },
                    onErrorResponse: (response) {
                      debugPrint('onErrorResponse:');
                      debugPrint(response.toJson().toString());
                    },
                  );
                },
                child: const Text('RequestSale')),
            ElevatedButton(
                onPressed: () async {
                  final saleRequest = RefundRequest(
                    transactionId: '',
                    amountDetails: const AmountDetails.refund(
                        currency: 'USD', amount: '1.00'),
                  );
                  PayzliPaymentPAX(widget.paxAcceptance).refund(
                    saleRequest,
                    onDoneApproved: (response) {
                      print('onDoneApproved:');
                      print(response.toJson());
                    },
                    onDoneAborted: (response) {
                      print('onDoneAborted:');
                      print(response.toJson());
                    },
                    onError: (error) {
                      print('onError:');
                      print(error);
                    },
                    onStatus: (response) {
                      print('onStatus:');
                      print(response.toJson());
                    },
                    onErrorResponse: (response) {
                      print('onErrorResponse:');
                      print(response.toJson());
                    },
                  );
                },
                child: const Text('Request refund')),
          ],
        )),
        SizedBox(
          height: 100,
          child: ElevatedButton(
            onPressed: () {
              widget.paxAcceptance.disconnect();
            },
            child: const Text('Disconnect'),
          ),
        ),
      ],
    );
  }
}
