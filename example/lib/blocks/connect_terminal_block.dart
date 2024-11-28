import 'package:flutter/material.dart';
import 'package:flutter_pax_acceptance/flutter_pax_acceptance.dart';

class ConnectTerminalBlock extends StatefulWidget {
  const ConnectTerminalBlock({super.key, required this.paxAcceptance});
  final FlutterPaxAcceptance paxAcceptance;
  @override
  State<ConnectTerminalBlock> createState() => _ConnectTerminalBlockState();
}

class _ConnectTerminalBlockState extends State<ConnectTerminalBlock> {
  late final TextEditingController paxIPController;

  @override
  void initState() {
    paxIPController = TextEditingController(text: widget.paxAcceptance.host);
    widget.paxAcceptance.addListener(onStateChange);

    super.initState();
  }

  @override
  void dispose() {
    widget.paxAcceptance.removeListener(onStateChange);
    super.dispose();
  }

  void onStateChange() {
    setState(() {
      isLoading = widget.paxAcceptance.isLoading;
    });
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'POS and Terminal not connected',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(builder: (context) {
              if (isLoading) {
                return const CircularProgressIndicator();
              }
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: paxIPController,
                      onChanged: (value) {},
                      onSubmitted: (value) {},
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text("IP Address")),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FilledButton(
                      onPressed: () async {
                        await widget.paxAcceptance.setHost(
                            paxIPController.text.split(':')[0] ?? '',
                            int.tryParse(paxIPController.text.split(':')[1]) ??
                                0);
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.pink),
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder())),
                      child: const Text('Save'))
                ],
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () async {
              if (isLoading) return;
              isLoading = true;
              final success = await widget.paxAcceptance.connect();
              if (!success) {
                const SnackBar(content: Text('Failed to connect'));
                showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                          title: Text('Failed to connect'),
                        ));
              }
              isLoading = false;
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.pink[400],
                  borderRadius: BorderRadius.circular(4)),
              child: const Text(
                'Connect',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
