import 'package:flutter/material.dart';
import 'package:flutter_pax_acceptance/flutter_pax_acceptance.dart';
import 'package:flutter_pax_acceptance/models/amount_details.dart';
import 'package:flutter_pax_acceptance/models/refund_request.dart';
import 'package:flutter_pax_acceptance/models/sale_payment_request.dart';
import 'package:flutter_pax_acceptance/payzli_payment_pax.dart';

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
