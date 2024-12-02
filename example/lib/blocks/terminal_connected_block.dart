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
                    amountDetails: const AmountDetails.sale(
                        currency: 'USD', amount: '1.00'),
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
                child: const Text('Request refund')),
            ElevatedButton(
                onPressed: () async {
                  const saleRequest = TransactionLookupRequest.fromTransactID(
                      id: '68412449aac14da2a1a7c09b0cb274a1');
                  PayzliPaymentPAX(widget.paxAcceptance).checkTransactionStatus(
                    saleRequest,
                    onDone: (response) {
                      debugPrint('onDoneApproved:');
                      debugPrint(response.toJson().toString());
                    },
                    onError: (error) {
                      debugPrint('onError:');
                      debugPrint(error);
                    },
                    onMidStatus: (response) {
                      debugPrint('onMidStatus:');
                      debugPrint(response.toJson().toString());
                    },
                    onErrorResponse: (response) {
                      debugPrint('onErrorResponse:');
                      debugPrint(response.toJson().toString());
                    },
                  );
                },
                child: const Text('Check transaction status')),
          ],
        )),
        Text('Completed transactions:'),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              children: [SelectableText('68412449aac14da2a1a7c09b0cb274a1')],
            ),
          ),
        ),
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
