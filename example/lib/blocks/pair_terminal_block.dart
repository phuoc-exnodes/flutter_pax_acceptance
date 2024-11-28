import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pax_acceptance/flutter_pax_acceptance.dart';

class PairTerminalBlockView extends StatefulWidget {
  const PairTerminalBlockView(this.paxAcceptance, {super.key});
  final FlutterPaxAcceptance paxAcceptance;

  @override
  State<PairTerminalBlockView> createState() => _PairTerminalBlockViewState();
}

class _PairTerminalBlockViewState extends State<PairTerminalBlockView> {
  TextEditingController paxIPController =
      TextEditingController(text: '192.168.:8443');

  TextEditingController paxCodeController = TextEditingController();
  FocusNode paxCodeFieldNode = FocusNode();
  FocusNode paxIPFieldNode = FocusNode();

  bool isPaxLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Builder(
          builder: (c) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Pair PAX terminal',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Center(
                        child: Builder(builder: (context) {
                          if (isPaxLoading) {
                            return const CircularProgressIndicator();
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                controller: paxIPController,
                                focusNode: paxIPFieldNode,
                                inputFormatters: [
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                      final newtext = newValue.text.trim();
                                      return newValue.copyWith(text: newtext);
                                    },
                                  ),
                                ],
                                decoration: const InputDecoration(
                                    label: Text('Enter PAX IP and Port'),
                                    hintText: 'IP:PORT',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder()),
                                onEditingComplete: () =>
                                    paxCodeFieldNode.requestFocus(),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextField(
                                controller: paxCodeController,
                                focusNode: paxCodeFieldNode,
                                decoration: const InputDecoration(
                                    label: Text('Enter code'),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    border: OutlineInputBorder()),
                              )
                            ],
                          );
                        }),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isPaxLoading = true;
                        });
                        try {
                          await widget.paxAcceptance.pairPAXTerminal(
                              ipAddress: paxIPController.text.split(':')[0],
                              port: int.parse(
                                paxIPController.text.split(':')[1],
                              ),
                              setupCode: paxCodeController.text);
                        } catch (e) {}

                        setState(() {
                          isPaxLoading = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.pink[300],
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text(
                          'PAIR',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }
}
